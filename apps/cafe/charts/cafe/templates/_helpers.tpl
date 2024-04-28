{{- define "ns-common.labels" -}}
act3-ace.io/part-of: cafe
tonygilkerson.us/alerting: enabled
cafe-gateway: enabled
{{- end }}

{{- define "ns-pod-security-baseline.labels" -}}
pod-security.kubernetes.io/enforce: baseline
pod-security.kubernetes.io/enforce-version: latest
pod-security.kubernetes.io/audit: baseline
pod-security.kubernetes.io/audit-version: latest
pod-security.kubernetes.io/warn: baseline
pod-security.kubernetes.io/warn-version: latest
{{- end }}

{{- define "ns-pod-security-privileged.labels" -}}
pod-security.kubernetes.io/enforce: privileged
pod-security.kubernetes.io/enforce-version: latest
pod-security.kubernetes.io/audit: privileged
pod-security.kubernetes.io/audit-version: latest
pod-security.kubernetes.io/warn: privileged
pod-security.kubernetes.io/warn-version: latest
{{- end }}

{{- define "ns-pod-security-restricted.labels" -}}
pod-security.kubernetes.io/enforce: restricted
pod-security.kubernetes.io/enforce-version: latest
pod-security.kubernetes.io/audit: restricted
pod-security.kubernetes.io/audit-version: latest
pod-security.kubernetes.io/warn: restricted
pod-security.kubernetes.io/warn-version: latest
{{- end }}