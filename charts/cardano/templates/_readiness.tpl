{{/* Init container that waits for EKG to be ready */}}
{{- define "cardano.readiness.waitForEkg" -}}
{{- $fullName := include "cardano.fullname" . }}
{{- $readinessHost := printf "%s-relay-0.%s-headless.%s.svc.cluster.local" $fullName $fullName .Release.Namespace }}
{{- $readinessPort := "12789" }}
- name: "wait-for-metrics"
  image: "{{- .Values.busybox.repository -}}:{{- .Values.busybox.tag | default .Chart.AppVersion -}}"
  imagePullPolicy: "IfNotPresent"
  env:
  - name: "READINESS_URL"
    value: http://{{- $readinessHost -}}:{{- $readinessPort -}}/metrics
  command: ["sh", "-c", "while true; do echo 'checking EKG readiness'; wget -T 5 --spider $READINESS_URL ; result=$?; if [ $result -eq 0 ]; then echo 'Success: EKG is ready!'; break; fi; echo '...not ready yet; sleeping 3 seconds before retry'; sleep 3; done;"]
{{- end -}}
