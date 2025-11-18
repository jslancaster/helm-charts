{{/*
Expand the name of the chart.
*/}}
{{- define "mealie.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mealie.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mealie.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mealie.labels" -}}
helm.sh/chart: {{ include "mealie.chart" . }}
{{ include "mealie.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mealie.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mealie.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mealie.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mealie.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Environment variables from ConfigMap
*/}}
{{- define "mealie.envFrom.configMap" -}}
- configMapRef:
    name: {{ include "mealie.fullname" . }}
{{- end }}

{{/*
Sensitive environment variables from Secrets
*/}}
{{- define "mealie.envVars.secrets" -}}
{{- if eq .Values.config.database.engine "postgres" }}
{{- if .Values.config.database.postgres.existingSecret }}
# PostgreSQL credentials from existing secret
- name: POSTGRES_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.database.postgres.existingSecret }}
      key: {{ .Values.config.database.postgres.existingSecretUsernameKey }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.database.postgres.existingSecret }}
      key: {{ .Values.config.database.postgres.existingSecretPasswordKey }}
- name: POSTGRES_SERVER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.database.postgres.existingSecret }}
      key: {{ .Values.config.database.postgres.existingSecretHostKey }}
- name: POSTGRES_PORT
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.database.postgres.existingSecret }}
      key: {{ .Values.config.database.postgres.existingSecretPortKey }}
- name: POSTGRES_DB
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.database.postgres.existingSecret }}
      key: {{ .Values.config.database.postgres.existingSecretDatabaseKey }}
{{- if .Values.config.database.postgres.urlOverride }}
- name: POSTGRES_URL_OVERRIDE
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.database.postgres.existingSecret }}
      key: {{ .Values.config.database.postgres.existingSecretUrlOverrideKey }}
{{- end }}
{{- else }}
# PostgreSQL credentials from inline values (DEVELOPMENT ONLY)
{{- if .Values.config.database.postgres.host }}
- name: POSTGRES_SERVER
  value: {{ .Values.config.database.postgres.host | quote }}
{{- end }}
{{- if .Values.config.database.postgres.username }}
- name: POSTGRES_USER
  value: {{ .Values.config.database.postgres.username | quote }}
{{- end }}
{{- if .Values.config.database.postgres.password }}
- name: POSTGRES_PASSWORD
  value: {{ .Values.config.database.postgres.password | quote }}
{{- end }}
{{- if .Values.config.database.postgres.urlOverride }}
- name: POSTGRES_URL_OVERRIDE
  value: {{ .Values.config.database.postgres.urlOverride | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.config.smtp.enabled }}
{{- if .Values.config.smtp.existingSecret }}
# SMTP credentials from existing secret
- name: SMTP_HOST
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.smtp.existingSecret }}
      key: {{ .Values.config.smtp.existingSecretHostKey }}
- name: SMTP_PORT
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.smtp.existingSecret }}
      key: {{ .Values.config.smtp.existingSecretPortKey }}
{{- if .Values.config.smtp.username }}
- name: SMTP_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.smtp.existingSecret }}
      key: {{ .Values.config.smtp.existingSecretUsernameKey }}
{{- end }}
{{- if .Values.config.smtp.password }}
- name: SMTP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.smtp.existingSecret }}
      key: {{ .Values.config.smtp.existingSecretPasswordKey }}
{{- end }}
{{- else }}
# SMTP credentials from inline values (DEVELOPMENT ONLY)
{{- if .Values.config.smtp.host }}
- name: SMTP_HOST
  value: {{ .Values.config.smtp.host | quote }}
{{- end }}
- name: SMTP_PORT
  value: {{ .Values.config.smtp.port | quote }}
{{- if .Values.config.smtp.username }}
- name: SMTP_USER
  value: {{ .Values.config.smtp.username | quote }}
{{- end }}
{{- if .Values.config.smtp.password }}
- name: SMTP_PASSWORD
  value: {{ .Values.config.smtp.password | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.config.ldap.enabled }}
{{- if .Values.config.ldap.existingSecret }}
# LDAP credentials from existing secret
- name: LDAP_SERVER_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.ldap.existingSecret }}
      key: {{ .Values.config.ldap.existingSecretServerUrlKey }}
{{- if .Values.config.ldap.queryBind }}
- name: LDAP_QUERY_BIND
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.ldap.existingSecret }}
      key: {{ .Values.config.ldap.existingSecretQueryBindKey }}
{{- end }}
{{- if .Values.config.ldap.queryPassword }}
- name: LDAP_QUERY_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.ldap.existingSecret }}
      key: {{ .Values.config.ldap.existingSecretQueryPasswordKey }}
{{- end }}
{{- else }}
# LDAP credentials from inline values (DEVELOPMENT ONLY)
{{- if .Values.config.ldap.serverUrl }}
- name: LDAP_SERVER_URL
  value: {{ .Values.config.ldap.serverUrl | quote }}
{{- end }}
{{- if .Values.config.ldap.queryBind }}
- name: LDAP_QUERY_BIND
  value: {{ .Values.config.ldap.queryBind | quote }}
{{- end }}
{{- if .Values.config.ldap.queryPassword }}
- name: LDAP_QUERY_PASSWORD
  value: {{ .Values.config.ldap.queryPassword | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.config.oidc.enabled }}
{{- if .Values.config.oidc.existingSecret }}
# OIDC credentials from existing secret
- name: OIDC_CONFIGURATION_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.oidc.existingSecret }}
      key: {{ .Values.config.oidc.existingSecretConfigurationUrlKey }}
- name: OIDC_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.oidc.existingSecret }}
      key: {{ .Values.config.oidc.existingSecretClientIdKey }}
{{- if .Values.config.oidc.clientSecret }}
- name: OIDC_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.oidc.existingSecret }}
      key: {{ .Values.config.oidc.existingSecretClientSecretKey }}
{{- end }}
{{- else }}
# OIDC credentials from inline values (DEVELOPMENT ONLY)
{{- if .Values.config.oidc.configurationUrl }}
- name: OIDC_CONFIGURATION_URL
  value: {{ .Values.config.oidc.configurationUrl | quote }}
{{- end }}
{{- if .Values.config.oidc.clientId }}
- name: OIDC_CLIENT_ID
  value: {{ .Values.config.oidc.clientId | quote }}
{{- end }}
{{- if .Values.config.oidc.clientSecret }}
- name: OIDC_CLIENT_SECRET
  value: {{ .Values.config.oidc.clientSecret | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.config.openai.enabled }}
{{- if .Values.config.openai.existingSecret }}
# OpenAI credentials from existing secret
{{- if .Values.config.openai.baseUrl }}
- name: OPENAI_BASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.openai.existingSecret }}
      key: {{ .Values.config.openai.existingSecretBaseUrlKey }}
{{- end }}
{{- if .Values.config.openai.apiKey }}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.openai.existingSecret }}
      key: {{ .Values.config.openai.existingSecretApiKeyKey }}
{{- end }}
{{- else }}
# OpenAI credentials from inline values (DEVELOPMENT ONLY)
{{- if .Values.config.openai.baseUrl }}
- name: OPENAI_BASE_URL
  value: {{ .Values.config.openai.baseUrl | quote }}
{{- end }}
{{- if .Values.config.openai.apiKey }}
- name: OPENAI_API_KEY
  value: {{ .Values.config.openai.apiKey | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Additional user-defined environment variables
*/}}
{{- define "mealie.envVars.extra" -}}
{{- range .Values.extraEnvVars }}
- name: {{ .name }}
  value: {{ .value | quote }}
{{- end }}
{{- end }}

{{/*
Check if using inline secrets (for warning in deployment)
*/}}
{{- define "mealie.usingInlineSecrets" -}}
{{- $usingInline := false -}}
{{- if eq .Values.config.database.engine "postgres" -}}
  {{- if and (not .Values.config.database.postgres.existingSecret) (or .Values.config.database.postgres.password .Values.config.database.postgres.host) -}}
    {{- $usingInline = true -}}
  {{- end -}}
{{- end -}}
{{- if and .Values.config.smtp.enabled (not .Values.config.smtp.existingSecret) (or .Values.config.smtp.password .Values.config.smtp.host) -}}
  {{- $usingInline = true -}}
{{- end -}}
{{- if and .Values.config.ldap.enabled (not .Values.config.ldap.existingSecret) (or .Values.config.ldap.queryPassword .Values.config.ldap.serverUrl) -}}
  {{- $usingInline = true -}}
{{- end -}}
{{- if and .Values.config.oidc.enabled (not .Values.config.oidc.existingSecret) (or .Values.config.oidc.clientSecret .Values.config.oidc.configurationUrl) -}}
  {{- $usingInline = true -}}
{{- end -}}
{{- if and .Values.config.openai.enabled (not .Values.config.openai.existingSecret) (or .Values.config.openai.apiKey .Values.config.openai.baseUrl) -}}
  {{- $usingInline = true -}}
{{- end -}}
{{- $usingInline -}}
{{- end }}