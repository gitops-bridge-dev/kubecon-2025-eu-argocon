{{/*
Expand the name of the chart.
*/}}
{{- define "vclusters.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vclusters.fullname" -}}
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
{{- define "vclusters.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vclusters.labels" -}}
helm.sh/chart: {{ include "vclusters.chart" . }}
{{ include "vclusters.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vclusters.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vclusters.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "vclusters.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vclusters.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
HELPER FOR cluster generators
*/}}


{{/*
Generate a name for each cluster configmap based on its properties
*/}}
{{- define "cluster-configmaps.clusterName" -}}
{{- $env := index . 0 -}}
{{- $region := index . 1 -}}
{{- $version := index . 2 -}}
{{- $org := index . 3 -}}
{{- printf "%s-%s-%s-%s" $env $region (regexReplaceAll "\\." $version "-") $org | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Calculate the total number of combinations
*/}}
{{- define "cluster-configmaps.totalCombinations" -}}
{{- $root := . -}}
{{- mul (len .Values.possibleValues.environments) (len .Values.possibleValues.regions) (len .Values.possibleValues.versions) (len .Values.possibleValues.organizations) -}}
{{- end -}}

{{/*
Get the letter corresponding to an index in the alphabet
*/}}
{{- define "cluster-configmaps.letterByIndex" -}}
{{- $index := . -}}
{{- $letters := list "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z" -}}
{{- index $letters $index -}}
{{- end -}}

{{/*
Calculate the group name based on environment, version count, and max clusters per group
*/}}
{{- define "cluster-configmaps.groupName" -}}
{{- $env := index . 0 -}}
{{- $count := index . 1 -}}
{{- $maxClustersPerGroup := 2 -}}
{{- $letterIndex := div $count $maxClustersPerGroup -}}
{{- $letter := include "cluster-configmaps.letterByIndex" $letterIndex -}}
{{- printf "%s-%s" $env $letter -}}
{{- end -}}