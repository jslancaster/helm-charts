# Mealie Helm Chart Testing Guide

This document describes the test suite for the Mealie Helm chart and how to use it.

## Overview

The Mealie chart includes comprehensive tests that validate the deployment configuration, connectivity, and functionality. Tests are implemented as Helm test hooks that run as Kubernetes pods.

## Running Tests

### Run All Tests

After installing the chart, run all tests:

```bash
helm test mealie
```

### Run Specific Tests

Use the `--filter` flag to run individual tests:

```bash
# Connection test
helm test mealie --filter name=mealie-test-connection

# ConfigMap test
helm test mealie --filter name=mealie-test-configmap

# Persistence test
helm test mealie --filter name=mealie-test-persistence

# API health test
helm test mealie --filter name=mealie-test-api-health

# Database config test (PostgreSQL only)
helm test mealie --filter name=mealie-test-database-config

# Service account test
helm test mealie --filter name=mealie-test-serviceaccount
```

## Test Descriptions

### 1. Connection Test (`test-connection.yaml`)

**Purpose**: Verifies basic network connectivity to the Mealie service

**What it tests**:
- Service is reachable on the configured port
- DNS resolution works correctly
- Network policies allow communication

**When it runs**: Always

**Expected behavior**:
- Uses `wget` to check if the service responds
- Retries up to 3 times with 10-second timeout
- Fails if service is not reachable

### 2. ConfigMap Test (`test-configmap.yaml`)

**Purpose**: Validates that environment variables from ConfigMap are correctly injected

**What it tests**:
- `DB_ENGINE` is set
- `BASE_URL` is set
- `TZ` (timezone) is set
- `API_PORT` is set

**When it runs**: Always

**Expected behavior**:
- Checks critical environment variables are present
- Does not validate values, only presence
- Fails if any required variable is missing

### 3. Persistence Test (`test-persistence.yaml`)

**Purpose**: Validates persistent volume configuration and access

**What it tests**:
- Data volume is mounted at the correct path
- Data directory is writable
- Backup volume is mounted (if enabled)
- Backup directory is writable (if enabled)

**When it runs**: Only when `persistence.enabled=true` and `persistence.data.enabled=true`

**Expected behavior**:
- Creates test files to verify write permissions
- Cleans up test files after verification
- Fails if volumes are not mounted or not writable

### 4. API Health Test (`test-api-health.yaml`)

**Purpose**: Validates that the Mealie application is healthy and responding

**What it tests**:
- Root endpoint (`/`) is accessible
- API docs endpoint (`/docs`) is accessible (if enabled)
- API health endpoint (`/api/app/about`) is accessible

**When it runs**: Always

**Expected behavior**:
- Waits up to 5 minutes for the application to become ready
- Retries every 10 seconds
- Tests multiple endpoints for comprehensive health check
- Fails if application doesn't respond within timeout

### 5. Database Config Test (`test-database-config.yaml`)

**Purpose**: Validates PostgreSQL database configuration

**What it tests**:
- `DB_ENGINE` is set to "postgres"
- `POSTGRES_SERVER` is set
- `POSTGRES_PORT` is set
- `POSTGRES_DB` is set
- `POSTGRES_USER` is set
- `POSTGRES_PASSWORD` is set
- Displays warning if using inline credentials

**When it runs**: Only when `config.database.engine=postgres`

**Expected behavior**:
- Verifies all required PostgreSQL environment variables are present
- Shows security warning if not using existing secrets
- Does not test actual database connectivity
- Fails if any required variable is missing

### 6. Service Account Test (`test-serviceaccount.yaml`)

**Purpose**: Validates service account configuration

**What it tests**:
- Service account token is mounted (if `serviceAccount.automount=true`)
- Service account token is NOT mounted (if `serviceAccount.automount=false`)
- Namespace information is available

**When it runs**: Only when `serviceAccount.create=true`

**Expected behavior**:
- Checks for presence/absence of service account token based on configuration
- Verifies namespace file exists
- Fails if token mounting doesn't match configuration

## Test Lifecycle

### Hook Annotations

All tests use the following Helm hook annotations:

```yaml
annotations:
  "helm.sh/hook": test
  "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
```

This means:
- Tests run when `helm test` is executed
- Test pods are deleted before running new tests
- Test pods are deleted after successful completion
- Failed test pods remain for debugging

### Viewing Test Logs

Get logs from a specific test:

```bash
kubectl logs mealie-test-connection
```

Get logs from all tests:

```bash
kubectl logs -l "helm.sh/hook=test"
```

### Cleaning Up Test Pods

If tests fail, pods remain for debugging. Clean them up manually:

```bash
# Delete all test pods
kubectl delete pod -l "helm.sh/hook=test"

# Delete a specific test pod
kubectl delete pod mealie-test-connection
```

## Conditional Test Execution

Some tests only run under certain conditions:

| Test | Condition |
|------|-----------|
| Connection | Always runs |
| ConfigMap | Always runs |
| Persistence | Only if `persistence.enabled=true` and `persistence.data.enabled=true` |
| API Health | Always runs |
| Database Config | Only if `config.database.engine=postgres` |
| Service Account | Only if `serviceAccount.create=true` |

## Example Test Scenarios

### Testing Default Installation (SQLite)

```bash
helm install mealie ./mealie
helm test mealie
```

**Expected tests**: Connection, ConfigMap, Persistence, API Health, Service Account

### Testing with PostgreSQL

```bash
helm install mealie ./mealie -f postgres-values.yaml
helm test mealie
```

**Expected tests**: All tests including Database Config

### Testing with Persistence Disabled

```bash
helm install mealie ./mealie --set persistence.enabled=false
helm test mealie
```

**Expected tests**: Connection, ConfigMap, API Health, Service Account (no Persistence test)

## Troubleshooting Failed Tests

### Connection Test Fails

**Possible causes**:
- Service not created correctly
- Network policies blocking traffic
- Service selector not matching pods

**Debug**:
```bash
kubectl get svc mealie
kubectl get pods -l app.kubernetes.io/name=mealie
kubectl describe svc mealie
```

### ConfigMap Test Fails

**Possible causes**:
- ConfigMap not created
- ConfigMap not mounted in pods
- Template rendering error

**Debug**:
```bash
kubectl get configmap mealie -o yaml
kubectl describe pod mealie-test-configmap
```

### Persistence Test Fails

**Possible causes**:
- PVC not created
- PVC not bound
- Storage class issues
- Volume mount permissions

**Debug**:
```bash
kubectl get pvc
kubectl describe pvc mealie-data
kubectl get storageclass
```

### API Health Test Fails

**Possible causes**:
- Application not starting correctly
- Database connection issues
- Configuration errors
- Insufficient resources

**Debug**:
```bash
kubectl logs -l app.kubernetes.io/name=mealie
kubectl describe pod -l app.kubernetes.io/name=mealie
kubectl get events --sort-by='.lastTimestamp'
```

### Database Config Test Fails

**Possible causes**:
- Missing environment variables
- Incorrect secret configuration
- Secret not created or not accessible

**Debug**:
```bash
kubectl get secret
kubectl describe pod mealie-test-database-config
# Check environment variables
kubectl exec mealie-test-database-config -- env | grep POSTGRES
```

### Service Account Test Fails

**Possible causes**:
- Service account not created
- Token automount setting mismatch
- RBAC permissions issue

**Debug**:
```bash
kubectl get serviceaccount mealie
kubectl describe serviceaccount mealie
```

## CI/CD Integration

The tests can be integrated into CI/CD pipelines:

```bash
#!/bin/bash
# Example CI/CD test script

# Install the chart
helm install mealie ./charts/mealie --wait --timeout 10m

# Run tests
helm test mealie --timeout 10m

# Check test results
if [ $? -eq 0 ]; then
  echo "All tests passed!"
  # Optionally clean up
  helm uninstall mealie
  exit 0
else
  echo "Tests failed! Collecting debug info..."
  kubectl logs -l "helm.sh/hook=test"
  kubectl get all
  exit 1
fi
```

## Writing New Tests

When adding new tests, follow these guidelines:

1. **Use Helm test hooks**:
   ```yaml
   annotations:
     "helm.sh/hook": test
     "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
   ```

2. **Use lightweight images**: Prefer `busybox` or `alpine` for simple tests

3. **Make tests idempotent**: Tests should not modify application state

4. **Provide clear output**: Use descriptive echo statements to explain what's being tested

5. **Handle conditions**: Use Helm conditionals to run tests only when relevant

6. **Set appropriate timeouts**: Consider application startup time

7. **Follow naming convention**: `test-<feature>.yaml`

## Best Practices

1. **Run tests after installation**: Always run `helm test` after deploying
2. **Run tests after upgrades**: Verify configuration changes with tests
3. **Monitor test execution time**: Long-running tests may indicate issues
4. **Keep test pods for debugging**: Don't immediately delete failed test pods
5. **Include tests in documentation**: Document any custom tests you add
6. **Test in dev first**: Run tests in development before production deployments

## Additional Resources

- [Helm Chart Tests Documentation](https://helm.sh/docs/topics/chart_tests/)
- [Kubernetes Pod Hooks](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination)
- [Mealie Documentation](https://docs.mealie.io/)
