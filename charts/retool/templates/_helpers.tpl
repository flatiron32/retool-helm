{{/*
Expand the name of the chart.
*/}}
{{- define "retool.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "retool.fullname" -}}
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
{{- define "retool.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "retool.labels" -}}
helm.sh/chart: {{ include "retool.chart" . }}
{{ include "retool.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "retool.selectorLabels" -}}
app.kubernetes.io/name: {{ include "retool.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "retool.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "retool.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "retool.postgresql.fullname" -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set postgresql ssl_enabled
*/}}
{{- define "retool.postgresql.ssl_enabled" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.ssl_enabled | quote -}}
{{- else -}}
{{- .Values.config.postgresql.ssl_enabled | quote -}}
{{- end -}}
{{- end -}}

{{/*
Set postgresql host
*/}}
{{- define "retool.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- include "retool.postgresql.fullname" . | quote -}}
{{- else -}}
{{- .Values.config.postgresql.host | quote -}}
{{- end -}}
{{- end -}}

{{/*
Set postgresql port
*/}}
{{- define "retool.postgresql.port" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.service.port | quote -}}
{{- else -}}
{{- .Values.config.postgresql.port | quote -}}
{{- end -}}
{{- end -}}

{{/*
Set postgresql db
*/}}
{{- define "retool.postgresql.database" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.database | quote -}}
{{- else if .Values.config.postgresql.db -}}
{{- .Values.config.postgresql.db | quote -}}
{{- else -}}
{{- .Values.config.postgresql.database | quote -}}
{{- end -}}
{{- end -}}

{{/*
Set postgresql user
*/}}
{{- define "retool.postgresql.user" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.username | quote -}}
{{- else -}}
{{- .Values.config.postgresql.user | quote -}}
{{- end -}}
{{- end -}}

{{/*
Set Workflows enabled
Usage: (include "retool.workflows.enabled" .)
*/}}
{{- define "retool.workflows.enabled" -}}
{{- $output := "" -}}
{{- if or (eq .Values.workflows.enabled true) (eq .Values.workflows.enabled false) -}}
  {{- if eq .Values.workflows.enabled true -}}
    {{- $output = "1" -}}
  {{- else -}}
    {{- $output = "" -}}
  {{- end -}}
{{- else if empty .Values.image.tag -}}
  {{- $output = "" -}}
{{- else if eq .Values.image.tag "latest" -}}
  {{- $output = "1" -}}
{{- else if semverCompare ">= 3.6.11" .Values.image.tag -}}
  {{- $output = "1" -}}
{{- else -}}
  {{- $output = "" -}}
{{- end -}}
{{- $output -}}
{{- end -}}

{{/*
Set Temporal enabled
Usage:  (include "retool.temporal.enabled" .)
*/}}
{{- define "retool.temporal.enabled" -}}
{{- $output := "" -}}
{{- if or (index .Values "retool-temporal-services-helm" "enabled") (.Values.workflows.temporal.enabled) -}}
  {{- $output = "1" -}}
{{- else -}}
  {{- $output = "" -}}
{{- end -}}
{{- $output -}}
{{- end -}}

{{/*
Set Temporal frontend host
*/}}
{{- define "retool.temporal.host" -}}
{{- if (.Values.workflows.temporal).enabled -}}
{{- .Values.workflows.temporal.host | quote -}}
{{- else -}}
{{- printf "%s-%s" (include "temporal.fullname" (index .Subcharts "retool-temporal-services-helm")) "frontend" -}}
{{- end -}}
{{- end -}}

{{/*
Set Temporal frontend port
*/}}
{{- define "retool.temporal.port" -}}
{{- if (.Values.workflows.temporal).enabled -}}
{{- .Values.workflows.temporal.port | quote -}}
{{- else -}}
{{- "7233" | quote -}}
{{- end -}}
{{- end -}}

{{/*
Set Temporal namespace
*/}}
{{- define "retool.temporal.namespace" -}}
{{- if (.Values.workflows.temporal).enabled -}}
{{- .Values.workflows.temporal.namespace | quote -}}
{{- else -}}
{{- "workflows" | quote -}}
{{- end -}}
{{- end -}}

{{/*
Set code executor service name
*/}}
{{- define "retool.codeExecutor.name" -}}
{{ template "retool.fullname" . }}-code-executor
{{- end -}}


{{/*
Set Worker enabled
Usage:  (include "retool.worker.enabled" .)
*/}}
{{- define "retool.worker.enabled" -}}
{{- $output := "" -}}
{{- if or (include "retool.workflows.enabled" .) (.Values.internalWorker.enabled) -}}
  {{- $output = "1" -}}
{{- else -}}
  {{- $output = "" -}}
{{- end -}}
{{- $output -}}
{{- end -}}
