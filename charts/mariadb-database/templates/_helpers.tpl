{{/*
Expand the name of the chart.
*/}}
{{- define "mariadb-database.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mariadb-database.fullname" -}}
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
{{- define "mariadb-database.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Tenant prefix: the release namespace with '-' replaced by '_'.
The platform's Kyverno tenancy policies REQUIRE database and user names to
carry this prefix — the chart derives it so releases pass by construction.
*/}}
{{- define "mariadb-database.tenantPrefix" -}}
{{- .Release.Namespace | replace "-" "_" }}
{{- end }}

{{/*
The actual database name on the shared cluster (prefixed, capped at 64 chars).
*/}}
{{- define "mariadb-database.dbName" -}}
{{- printf "%s_%s" (include "mariadb-database.tenantPrefix" .) .Values.auth.database | trunc 64 | trimSuffix "_" }}
{{- end }}

{{/*
The actual user name on the shared cluster (prefixed, capped at 64 chars).
*/}}
{{- define "mariadb-database.userName" -}}
{{- printf "%s_%s" (include "mariadb-database.tenantPrefix" .) .Values.auth.username | trunc 64 | trimSuffix "_" }}
{{- end }}

{{/*
Stable in-cluster hostname of the shared cluster (FQDN — tenants are in a
different namespace than the server).
*/}}
{{- define "mariadb-database.host" -}}
{{- printf "%s.%s.svc.cluster.local" .Values.cluster.name .Values.cluster.namespace }}
{{- end }}

{{/*
cleanupPolicy for all SQL CRs: Delete drops the object in the database when the
CR is deleted (helm uninstall); Skip leaves the data in place.
*/}}
{{- define "mariadb-database.cleanupPolicy" -}}
{{- if .Values.lifecycle.retainOnDelete }}Skip{{- else }}Delete{{- end }}
{{- end }}

{{/*
maxUserConnections from the connection tier.
*/}}
{{- define "mariadb-database.maxUserConnections" -}}
{{- $tiers := dict "small" 10 "medium" 50 "large" 200 }}
{{- get $tiers .Values.connections.tier | default 10 }}
{{- end }}
