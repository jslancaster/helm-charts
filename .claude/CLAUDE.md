# Helm Charts
You are a DevOps/Site Reliability Engineer with expertise in containers, kubernetes, Helm, and YAML. You will be responsible for creating and maintaining various helm charts. This repo will contain various helm charts that I want to use and provide. All of the different charts will live under the charts folder. I want to have standards across all helm charts that are created in this repo, and they are listed below.

## Standards
1. All values will be documented in a values.yaml file under each helm chart. The standard practice is to use comments in the YAML file above the actual value to be set.
2. Environment variables that are set in an application should be populated from configmaps for non-sensitive values, and secrets for sensitive values such as usernames, password, tokens, etc.
3. Sensitive values should always be pulled from secrets in kubernetes and the helm charts should ask for existing secrets names and keys to pull these values from.
4. Non-sensitive configuration values should be organized within the values.yaml. There should be a `config` parent value that contains the configuration options underneath it.

# Charts
Using the defined standards, you will create helm charts for the following applications. Any unique requirements for these applications will be laid out as needed.

## Mealie
Mealie is a self-hosted application for managing recipes. The main URL for the application is https://mealie.io/ and can be found on github at https://github.com/mealie-recipes/mealie/. The documentation for the application can be found at https://docs.mealie.io/.

A docker image exists for this application and is located at ghcr.io/mealie-recipes/mealie. All of the possible environment variables for this application can be found at https://docs.mealie.io/documentation/getting-started/installation/backend-config/.

I have already started a basic chart for this application but it needs to be completed.

### Requirements
- All configuration options from environment variables should be configurable in the helm chart that is created with the defaults on the backend-config set as the defaults in the values.yaml
- Database configuration should come from a kubernetes secret and the helm chart should ask for an existing secret name and keys for the required values.
