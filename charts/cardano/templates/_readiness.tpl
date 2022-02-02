{{/* Init container that waits for EKG to be ready */}}
{{- define "cardano.readiness.waitForEkg" -}}
{{- $fullName := include "cardano.fullname" . }}
{{- $readinessHost := printf "%s-relay-0.%s-headless.%s.svc.cluster.local" $fullName $fullName .Release.Namespace }}
{{- $readinessPort := "12789" }}
- name: "wait-for-metrics"
  securityContext:
    readOnlyRootFilesystem: true
  image: "{{- .Values.busybox.repository -}}:{{- .Values.busybox.tag -}}"
  imagePullPolicy: "IfNotPresent"
  env:
  - name: "READINESS_URL"
    value: http://{{- $readinessHost -}}:{{- $readinessPort -}}/metrics
  command: ["sh", "-c", "while true; do echo 'checking EKG readiness'; wget -T 5 --spider $READINESS_URL ; result=$?; if [ $result -eq 0 ]; then echo 'Success: EKG is ready!'; break; fi; echo '...not ready yet; sleeping 3 seconds before retry'; sleep 3; done;"]
{{- end -}}

{{- define "cardano.readiness.waitForP2p" -}}
{{- $fullName := include "cardano.fullname" . }}
{{- $readinessHost := printf "%s-p2p.%s.svc.cluster.local" $fullName .Release.Namespace }}
{{- $readinessPort := .Values.p2p.service.port }}
- name: "wait-for-p2p"
  securityContext:
    readOnlyRootFilesystem: true
  image: "{{- .Values.busybox.repository -}}:{{- .Values.busybox.tag -}}"
  imagePullPolicy: "IfNotPresent"
  env:
  - name: "READINESS_URL"
    value: http://{{- $readinessHost -}}:{{- $readinessPort -}}/health
  command: ["sh", "-c", "while true; do echo 'checking P2P readiness'; wget -T 5 --spider $READINESS_URL ; result=$?; if [ $result -eq 0 ]; then echo 'Success: P2P is ready!'; break; fi; echo '...not ready yet; sleeping 3 seconds before retry'; sleep 3; done;"]
{{- end -}}
