# Mealie Helm Chart

A Helm chart for deploying [Mealie](https://mealie.io/) - a self-hosted recipe manager and meal planner.

## Introduction

This chart bootstraps a Mealie deployment on a Kubernetes cluster using the Helm package manager. Mealie is a self-hosted recipe manager and meal planner with a REST API backend and a reactive frontend application built in Vue.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `mealie`:

```bash
helm install mealie ./mealie
```

This command deploys Mealie on the Kubernetes cluster with default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `mealie` deployment:

```bash
helm uninstall mealie
```

This command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

### Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.registry` | Container image registry | `ghcr.io` |
| `image.repository` | Container image repository | `mealie-recipes/mealie` |
| `image.tag` | Container image tag (overrides chart appVersion) | `""` |
| `image.pullPolicy` | Container image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Container image pull secrets | `[]` |

### Deployment Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of Mealie replicas | `1` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full chart name | `""` |

### Service Account

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.automount` | Automount service account token | `true` |
| `serviceAccount.annotations` | Service account annotations | `{}` |
| `serviceAccount.name` | Service account name (generated if not set) | `""` |

### Pod Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podAnnotations` | Pod annotations | `{}` |
| `podLabels` | Pod labels | `{}` |
| `podSecurityContext` | Pod security context | `{}` |
| `securityContext` | Container security context | `{}` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `9000` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | Ingress TLS configuration | `[]` |

### HTTPRoute Configuration (Gateway API)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `httpRoute.enabled` | Enable HTTPRoute | `false` |
| `httpRoute.annotations` | HTTPRoute annotations | `{}` |
| `httpRoute.parentRefs` | Gateway references | See values.yaml |
| `httpRoute.hostnames` | HTTPRoute hostnames | See values.yaml |
| `httpRoute.rules` | HTTPRoute rules | See values.yaml |

### Resource Limits

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources` | CPU/Memory resource requests/limits | `{}` |

### Health Probes

| Parameter | Description | Default |
|-----------|-------------|---------|
| `livenessProbe` | Liveness probe configuration | HTTP GET on / |
| `readinessProbe` | Readiness probe configuration | HTTP GET on / |

### Autoscaling

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable autoscaling | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `100` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization | `80` |

### Node Selection

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Tolerations for pod assignment | `[]` |
| `affinity` | Affinity rules for pod assignment | `{}` |

### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.data.enabled` | Enable data volume | `true` |
| `persistence.data.existingClaim` | Use existing PVC for data | `""` |
| `persistence.data.storageClass` | Storage class for data volume | `""` |
| `persistence.data.accessMode` | Access mode for data volume | `ReadWriteOnce` |
| `persistence.data.size` | Size of data volume | `10Gi` |
| `persistence.data.mountPath` | Mount path for data volume | `/app/data` |
| `persistence.backup.enabled` | Enable backup volume | `false` |
| `persistence.backup.existingClaim` | Use existing PVC for backups | `""` |
| `persistence.backup.storageClass` | Storage class for backup volume | `""` |
| `persistence.backup.accessMode` | Access mode for backup volume | `ReadWriteOnce` |
| `persistence.backup.size` | Size of backup volume | `5Gi` |
| `persistence.backup.mountPath` | Mount path for backup volume | `/app/backups` |

### Mealie Configuration

All Mealie-specific configuration is under the `config` key.

#### General Application Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.puid` | User ID for container permissions | `911` |
| `config.pgid` | Group ID for container permissions | `911` |
| `config.defaultGroup` | Default group for new users | `Home` |
| `config.defaultHousehold` | Default household for users | `Family` |
| `config.baseUrl` | Base URL for notifications and external references | `http://localhost:8080` |
| `config.tokenTime` | Auth token validity in hours | `48` |
| `config.apiPort` | Backend API port | `9000` |
| `config.apiDocs` | Enable local API documentation | `true` |
| `config.timezone` | Server timezone | `UTC` |
| `config.allowSignup` | Allow user registration without token | `false` |
| `config.allowPasswordLogin` | Display username/password login | `true` |
| `config.logConfigOverride` | Custom logging configuration path | `""` |
| `config.logLevel` | Logging verbosity level | `info` |
| `config.dailyScheduleTime` | Daily task execution time (HH:MM) | `23:45` |

#### Security Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.securityMaxLoginAttempts` | Max login attempts before lockout | `5` |
| `config.securityUserLockoutTime` | Account lockout duration in hours | `24` |

#### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.database.engine` | Database engine (sqlite or postgres) | `sqlite` |
| `config.database.sqlite.migrateJournalWal` | Enable WAL mode for SQLite | `false` |

##### PostgreSQL Configuration

> **Note**: For production deployments, use `existingSecret` to provide credentials securely.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.database.postgres.host` | PostgreSQL server address (inline) | `""` |
| `config.database.postgres.port` | PostgreSQL server port | `5432` |
| `config.database.postgres.database` | PostgreSQL database name | `mealie` |
| `config.database.postgres.username` | PostgreSQL username (inline) | `mealie` |
| `config.database.postgres.password` | PostgreSQL password (inline - dev only) | `""` |
| `config.database.postgres.urlOverride` | Complete database URL override | `""` |
| `config.database.postgres.existingSecret` | Existing secret name for credentials | `""` |
| `config.database.postgres.existingSecretHostKey` | Key in secret for host | `host` |
| `config.database.postgres.existingSecretPortKey` | Key in secret for port | `port` |
| `config.database.postgres.existingSecretDatabaseKey` | Key in secret for database | `database` |
| `config.database.postgres.existingSecretUsernameKey` | Key in secret for username | `username` |
| `config.database.postgres.existingSecretPasswordKey` | Key in secret for password | `password` |
| `config.database.postgres.existingSecretUrlOverrideKey` | Key in secret for URL override | `url` |

#### SMTP Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.smtp.enabled` | Enable SMTP email functionality | `false` |
| `config.smtp.host` | SMTP server host (inline) | `""` |
| `config.smtp.port` | SMTP server port | `587` |
| `config.smtp.fromName` | Sender display name | `Mealie` |
| `config.smtp.fromEmail` | Sender email address | `""` |
| `config.smtp.authStrategy` | Authentication method (TLS/SSL/NONE) | `TLS` |
| `config.smtp.username` | SMTP username (inline) | `""` |
| `config.smtp.password` | SMTP password (inline - dev only) | `""` |
| `config.smtp.existingSecret` | Existing secret name for SMTP credentials | `""` |
| `config.smtp.existingSecretHostKey` | Key in secret for host | `host` |
| `config.smtp.existingSecretPortKey` | Key in secret for port | `port` |
| `config.smtp.existingSecretUsernameKey` | Key in secret for username | `username` |
| `config.smtp.existingSecretPasswordKey` | Key in secret for password | `password` |

#### Web Server Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.uvicornWorkers` | Number of web server worker processes | `1` |

#### TLS/SSL Certificates

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.tls.certificatePath` | Path to SSL certificate file | `""` |
| `config.tls.privateKeyPath` | Path to private key file | `""` |

#### LDAP Authentication

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.ldap.enabled` | Enable LDAP authentication | `false` |
| `config.ldap.serverUrl` | LDAP server URL (inline) | `""` |
| `config.ldap.tlsInsecure` | Skip certificate verification | `false` |
| `config.ldap.tlsCacertfile` | Path to CA certificate | `""` |
| `config.ldap.enableStarttls` | Use STARTTLS | `false` |
| `config.ldap.baseDn` | Base DN for user searches | `""` |
| `config.ldap.queryBind` | Bind user for queries (inline) | `""` |
| `config.ldap.queryPassword` | Bind user password (inline - dev only) | `""` |
| `config.ldap.userFilter` | Filter for eligible users | `""` |
| `config.ldap.adminFilter` | Filter for admin users | `""` |
| `config.ldap.idAttribute` | Attribute for user ID | `uid` |
| `config.ldap.nameAttribute` | Attribute for user name | `name` |
| `config.ldap.mailAttribute` | Attribute for user email | `mail` |
| `config.ldap.existingSecret` | Existing secret name for LDAP credentials | `""` |
| `config.ldap.existingSecretServerUrlKey` | Key in secret for server URL | `serverUrl` |
| `config.ldap.existingSecretQueryBindKey` | Key in secret for bind user | `queryBind` |
| `config.ldap.existingSecretQueryPasswordKey` | Key in secret for bind password | `queryPassword` |

#### OIDC Authentication

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.oidc.enabled` | Enable OIDC authentication | `false` |
| `config.oidc.signupEnabled` | Allow new user creation via OIDC | `true` |
| `config.oidc.configurationUrl` | Provider configuration URL (inline) | `""` |
| `config.oidc.clientId` | Client ID (inline) | `""` |
| `config.oidc.clientSecret` | Client secret (inline - dev only) | `""` |
| `config.oidc.userGroup` | Restrict login to this group | `""` |
| `config.oidc.adminGroup` | Group granting admin status | `""` |
| `config.oidc.autoRedirect` | Auto-redirect to OIDC | `false` |
| `config.oidc.providerName` | Display name on login button | `OAuth` |
| `config.oidc.rememberMe` | Extend session automatically | `false` |
| `config.oidc.signingAlgorithm` | Token signing method | `RS256` |
| `config.oidc.userClaim` | Claim for user identification | `email` |
| `config.oidc.nameClaim` | Claim for user name | `name` |
| `config.oidc.groupsClaim` | Claim for group membership | `groups` |
| `config.oidc.scopesOverride` | Override requested scopes | `""` |
| `config.oidc.tlsCacertfile` | Path to CA certificate | `""` |
| `config.oidc.existingSecret` | Existing secret name for OIDC credentials | `""` |
| `config.oidc.existingSecretConfigurationUrlKey` | Key in secret for configuration URL | `configurationUrl` |
| `config.oidc.existingSecretClientIdKey` | Key in secret for client ID | `clientId` |
| `config.oidc.existingSecretClientSecretKey` | Key in secret for client secret | `clientSecret` |

#### OpenAI Integration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.openai.enabled` | Enable OpenAI integration | `false` |
| `config.openai.baseUrl` | Custom API endpoint (inline) | `""` |
| `config.openai.apiKey` | API key (inline - dev only) | `""` |
| `config.openai.model` | Model selection | `gpt-4o` |
| `config.openai.customHeaders` | JSON-encoded custom headers | `""` |
| `config.openai.customParams` | JSON-encoded query parameters | `""` |
| `config.openai.enableImageServices` | Enable image processing | `true` |
| `config.openai.workers` | Worker threads per request | `2` |
| `config.openai.sendDatabaseData` | Send Mealie data to OpenAI | `true` |
| `config.openai.requestTimeout` | Request timeout in seconds | `300` |
| `config.openai.existingSecret` | Existing secret name for OpenAI credentials | `""` |
| `config.openai.existingSecretBaseUrlKey` | Key in secret for base URL | `baseUrl` |
| `config.openai.existingSecretApiKeyKey` | Key in secret for API key | `apiKey` |

#### Theme Customization

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.theme.light.primary` | Light theme primary color | `#E58325` |
| `config.theme.light.accent` | Light theme accent color | `#007A99` |
| `config.theme.light.secondary` | Light theme secondary color | `#973542` |
| `config.theme.light.success` | Light theme success color | `#43A047` |
| `config.theme.light.info` | Light theme info color | `#1976D2` |
| `config.theme.light.warning` | Light theme warning color | `#FF6D00` |
| `config.theme.light.error` | Light theme error color | `#EF5350` |
| `config.theme.dark.primary` | Dark theme primary color | `#E58325` |
| `config.theme.dark.accent` | Dark theme accent color | `#007A99` |
| `config.theme.dark.secondary` | Dark theme secondary color | `#973542` |
| `config.theme.dark.success` | Dark theme success color | `#43A047` |
| `config.theme.dark.info` | Dark theme info color | `#1976D2` |
| `config.theme.dark.warning` | Dark theme warning color | `#FF6D00` |
| `config.theme.dark.error` | Dark theme error color | `#EF5350` |

### Extra Environment Variables

| Parameter | Description | Default |
|-----------|-------------|---------|
| `extraEnvVars` | Additional environment variables | `[]` |

Example:
```yaml
extraEnvVars:
  - name: CUSTOM_VAR
    value: "custom_value"
```

## Usage Examples

### Default Installation (SQLite)

```bash
helm install mealie ./mealie
```

This installs Mealie with:
- SQLite database
- 10Gi persistent storage
- Default configuration values

### PostgreSQL with Existing Secret

First, create a secret with your database credentials:

```bash
kubectl create secret generic mealie-db-secret \
  --from-literal=host=postgres.example.com \
  --from-literal=port=5432 \
  --from-literal=database=mealie \
  --from-literal=username=mealie \
  --from-literal=password=supersecret
```

Then install with:

```yaml
# values.yaml
config:
  database:
    engine: postgres
    postgres:
      existingSecret: mealie-db-secret
```

```bash
helm install mealie ./mealie -f values.yaml
```

### PostgreSQL with Inline Credentials (Development Only)

```yaml
# values-dev.yaml
config:
  database:
    engine: postgres
    postgres:
      host: postgres.default.svc.cluster.local
      username: mealie
      password: devpassword
      database: mealie
```

```bash
helm install mealie ./mealie -f values-dev.yaml
```

> **Warning**: This will display a warning as inline credentials are only recommended for development/testing.

### With Ingress

```yaml
# values.yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: mealie.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: mealie-tls
      hosts:
        - mealie.example.com

config:
  baseUrl: https://mealie.example.com
```

```bash
helm install mealie ./mealie -f values.yaml
```

### With SMTP Email

```bash
kubectl create secret generic mealie-smtp-secret \
  --from-literal=host=smtp.gmail.com \
  --from-literal=port=587 \
  --from-literal=username=your-email@gmail.com \
  --from-literal=password=your-app-password
```

```yaml
# values.yaml
config:
  smtp:
    enabled: true
    fromName: "Mealie Recipes"
    fromEmail: "your-email@gmail.com"
    authStrategy: "TLS"
    existingSecret: mealie-smtp-secret
```

```bash
helm install mealie ./mealie -f values.yaml
```

## Security Best Practices

### Production Deployments

For production deployments, **always** use Kubernetes secrets for sensitive data:

1. **Database credentials**: Use `config.database.postgres.existingSecret`
2. **SMTP passwords**: Use `config.smtp.existingSecret`
3. **LDAP credentials**: Use `config.ldap.existingSecret`
4. **OIDC secrets**: Use `config.oidc.existingSecret`
5. **OpenAI API keys**: Use `config.openai.existingSecret`

### Development/Testing

Inline credentials are supported for convenience during development:

```yaml
config:
  database:
    engine: postgres
    postgres:
      host: localhost
      username: mealie
      password: devpassword  # Only for dev/testing!
```

The chart will display warnings when inline secrets are detected.

## Upgrading

### From Inline to Secret-based Configuration

1. Create the secret:
```bash
kubectl create secret generic mealie-db \
  --from-literal=host=your-host \
  --from-literal=username=your-user \
  --from-literal=password=your-password \
  --from-literal=database=mealie
```

2. Update your values:
```yaml
config:
  database:
    postgres:
      existingSecret: mealie-db
      # Remove inline credentials
      host: ""
      username: ""
      password: ""
```

3. Upgrade the release:
```bash
helm upgrade mealie ./mealie -f values.yaml
```

## Testing

The chart includes comprehensive tests to validate the deployment. Run tests after installing the chart:

```bash
helm test mealie
```

### Available Tests

The chart includes the following test suites:

1. **Connection Test** - Verifies the Mealie service is reachable
2. **ConfigMap Test** - Validates all required environment variables are set correctly
3. **Persistence Test** - Checks persistent volumes are mounted and writable (only runs if persistence is enabled)
4. **API Health Test** - Validates the Mealie API is responding correctly
5. **Database Config Test** - Verifies PostgreSQL configuration (only runs when PostgreSQL is enabled)
6. **Service Account Test** - Validates service account configuration

### Running Individual Tests

To run a specific test:

```bash
# Run only the connection test
helm test mealie --filter name=mealie-test-connection

# Run only the API health test
helm test mealie --filter name=mealie-test-api-health
```

### Test Output

View test logs:

```bash
# Get logs from a specific test pod
kubectl logs mealie-test-connection

# Get logs from all test pods
kubectl logs -l "helm.sh/hook=test"
```

### Cleanup Test Pods

Test pods are automatically cleaned up on success, but you can manually remove them:

```bash
kubectl delete pod -l "helm.sh/hook=test"
```

## Troubleshooting

### Pod fails to start with database connection error

Check that:
1. Database credentials are correct
2. Database server is reachable from the cluster
3. Database exists and user has proper permissions

View logs:
```bash
kubectl logs -l app.kubernetes.io/name=mealie
```

### Persistent volume not mounting

Check PVC status:
```bash
kubectl get pvc
```

Verify storage class exists:
```bash
kubectl get storageclass
```

### Application shows old data after upgrade

Mealie uses persistent storage. Data persists across pod restarts and upgrades.

To start fresh, delete the PVC (this will delete all data):
```bash
kubectl delete pvc mealie-data
helm upgrade mealie ./mealie
```

## Contributing

For issues and feature requests, please use the GitHub repository issue tracker.

## License

This Helm chart is provided as-is. Mealie itself is licensed under the AGPL-3.0 License.
