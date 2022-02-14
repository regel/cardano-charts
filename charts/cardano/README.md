# cardano

![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.33.1](https://img.shields.io/badge/AppVersion-1.33.1-informational?style=flat-square)

A Cardano Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | common | 1.8.0 |
| https://charts.bitnami.com/bitnami | redis | 16.4.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| admin | object | `{"pullPolicy":"IfNotPresent","repository":"inputoutput/cardano-node","tag":"1.33.1"}` | The admin pod is a special pod. This pod is air-gapped (nothing in, nothing out) and mounts cold keys from a Vault. Use this pod for admin operations such as KES key signature and node certificate signature |
| busybox.pullPolicy | string | `"IfNotPresent"` |  |
| busybox.repository | string | `"busybox"` |  |
| busybox.tag | string | `"1.35.0"` |  |
| curl.pullPolicy | string | `"IfNotPresent"` |  |
| curl.repository | string | `"curlimages/curl"` |  |
| curl.tag | string | `"7.80.0"` |  |
| environment.name | string | `"testnet"` | name of the Cardano network to use. Either 'testnet' or 'mainnet' |
| fullnameOverride | string | `""` |  |
| global.redis.servicePort | int | `6379` |  |
| global.storageClass | string | `nil` | Global StorageClass for Persistent Volume(s) |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"inputoutput/cardano-node"` |  |
| image.tag | string | `"1.33.1"` | Overrides the image tag whose default is the chart appVersion. See [here](https://hub.docker.com/r/inputoutput/cardano-node/tags?page=1&ordering=last_updated) the full list of tags. |
| imagePullSecrets | list | `[]` |  |
| liveness.pullPolicy | string | `"IfNotPresent"` |  |
| liveness.repository | string | `"alpine"` |  |
| liveness.tag | string | `"3.12"` |  |
| metrics.enabled | bool | `false` | Start a prometheus exporter to expose metrics |
| metrics.serviceMonitor | object | `{"additionalLabels":{"release":"prometheus"},"enabled":false,"honorLabels":false,"interval":"30s","metricRelabelings":[],"namespace":"","relabellings":[],"scrapeTimeout":""}` | Prometheus Service Monitor ref: https://github.com/coreos/prometheus-operator      https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#endpoint |
| metrics.serviceMonitor.additionalLabels | object | `{"release":"prometheus"}` | Additional labels that can be used so ServiceMonitor resource(s) can be discovered by Prometheus |
| metrics.serviceMonitor.enabled | bool | `false` | Create ServiceMonitor resource(s) for scraping metrics using PrometheusOperator |
| metrics.serviceMonitor.honorLabels | bool | `false` | Specify honorLabels parameter to add the scrape endpoint |
| metrics.serviceMonitor.interval | string | `"30s"` | The interval at which metrics should be scraped |
| metrics.serviceMonitor.metricRelabelings | list | `[]` | Metrics RelabelConfigs to apply to samples before ingestion. |
| metrics.serviceMonitor.namespace | string | `""` | The namespace in which the ServiceMonitor will be created |
| metrics.serviceMonitor.relabellings | list | `[]` | Metrics RelabelConfigs to apply to samples before scraping. |
| metrics.serviceMonitor.scrapeTimeout | string | `""` | The timeout after which the scrape is ended |
| nameOverride | string | `""` |  |
| networkPolicy | object | `{"enabled":true}` | Network Policy configuration ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/ recipes: https://github.com/ahmetb/kubernetes-network-policy-recipes |
| networkPolicy.enabled | bool | `true` | Enable creation of NetworkPolicy resources |
| ogmios.enabled | bool | `true` |  |
| ogmios.pullPolicy | string | `"IfNotPresent"` |  |
| ogmios.readinessProbe | object | `{"enabled":true,"failureThreshold":5,"initialDelaySeconds":20,"periodSeconds":5,"successThreshold":1,"timeoutSeconds":1}` | Configure readiness probe for ogmios sidecar container |
| ogmios.readinessProbe.failureThreshold | int | `5` | Failure threshold for readinessProbe |
| ogmios.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| ogmios.readinessProbe.periodSeconds | int | `5` | Period seconds for readinessProbe |
| ogmios.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| ogmios.readinessProbe.timeoutSeconds | int | `1` | Timeout seconds for readinessProbe |
| ogmios.repository | string | `"cardanosolutions/ogmios"` |  |
| ogmios.resources | object | `{"limits":{"cpu":"200m","memory":"100Mi"},"requests":{"cpu":"100m","memory":"100Mi"}}` | Cardano ogmios ws bridge resource requests and limits ref: http://kubernetes.io/docs/user-guide/compute-resources/ |
| ogmios.resources.limits | object | `{"cpu":"200m","memory":"100Mi"}` | The resources limits for the Ogmios ws bridge container |
| ogmios.resources.requests | object | `{"cpu":"100m","memory":"100Mi"}` | The requested resources for the Ogmios ws bridge container |
| ogmios.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| ogmios.service.annotations | object | `{}` |  |
| ogmios.service.port | int | `1337` |  |
| ogmios.service.type | string | `"ClusterIP"` |  |
| ogmios.tag | string | `"latest"` |  |
| p2p | object | `{"clioEnabled":true,"debug":false,"ekgTimeout":5,"enabled":true,"ipVersion":4,"livenessProbe":{"enabled":true,"failureThreshold":1,"initialDelaySeconds":60,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"maxPeers":10,"probeTimeout":"1s","pullPolicy":"IfNotPresent","readinessProbe":{"enabled":true,"failureThreshold":10,"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"replicaCount":1,"repository":"regel/cardano-p2p","service":{"annotations":{},"port":8080,"type":"ClusterIP"},"tag":"v0.1.5","topic":"p2p"}` | P2P discovery configuration ref: https://github.com/regel/cardano-p2p |
| p2p.clioEnabled | bool | `true` | Use 'clio' to push blockNo to the CLIO service |
| p2p.enabled | bool | `true` | Enable peer to peer Cardano node discovery |
| p2p.livenessProbe.enabled | bool | `true` | Enable livenessProbe on p2p node |
| p2p.livenessProbe.failureThreshold | int | `1` | Failure threshold for livenessProbe |
| p2p.livenessProbe.initialDelaySeconds | int | `60` | Initial delay seconds for livenessProbe |
| p2p.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| p2p.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| p2p.livenessProbe.timeoutSeconds | int | `1` | Timeout seconds for livenessProbe |
| p2p.readinessProbe.enabled | bool | `true` | Enable readinessProbe on p2p nginx node |
| p2p.readinessProbe.failureThreshold | int | `10` | Failure threshold for readinessProbe |
| p2p.readinessProbe.initialDelaySeconds | int | `10` | Initial delay seconds for readinessProbe |
| p2p.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| p2p.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| p2p.readinessProbe.timeoutSeconds | int | `1` | Timeout seconds for readinessProbe |
| p2p.repository | string | `"regel/cardano-p2p"` | Repository of the cardano-p2p image ref: https://hub.docker.com/r/regel/cardano-p2p |
| persistence.accessModes | list | `["ReadWriteOnce"]` | PVC Access Mode for data volume |
| persistence.annotations | object | `{}` | Annotations for the PVC |
| persistence.enabled | bool | `true` | Enable persistence using PVC |
| persistence.existingClaim | string | `nil` | Provide an existing `PersistentVolumeClaim`, the value is evaluated as a template. If defined, PVC must be created manually before volume will be bound The value is evaluated as a template, so, for example, the name can depend on .Release or .Chart |
| persistence.mountPath | string | `"/data"` | The path the volume will be mounted at |
| persistence.selector | object | `{}` | Selector to match an existing Persistent Volume (this value is evaluated as a template) selector:   matchLabels:     app: my-app |
| persistence.size | string | `"8Gi"` | PVC Storage Request for data volume |
| persistence.sourceFile | object | `{"enabled":false,"url":""}` | Source file to download and uncompress if the PVC is empty |
| persistence.sourceFile.enabled | bool | `false` | Enable restore of the ledger database |
| persistence.sourceFile.url | string | `""` | download url of the ledger database archive. The tar.gz archive must contain the content of cardano 'db' directory. Store this file on a CDN or Azure Blob storage container to speed up download times. |
| persistence.storageClass | string | `nil` | PVC Storage Class for data volume If defined, storageClassName: <storageClass> If set to "-", storageClassName: "", which disables dynamic provisioning If undefined (the default) or set to null, no storageClassName spec is   set, choosing the default provisioner.  (gp2 on AWS, standard on   GKE, AWS & OpenStack) |
| persistence.subPath | string | `""` | The subdirectory of the volume to mount to Useful in dev environments and one PV for multiple services |
| podAnnotations."prometheus.io/port" | string | `"12789"` |  |
| podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| podSecurityContext.fsGroup | int | `65532` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `65532` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| producer.affinity | object | `{}` | Affinity for Cardano producer pods assignment ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity NOTE: `master.podAffinityPreset`, `master.podAntiAffinityPreset`, and `master.nodeAffinityPreset` will be ignored when it's set |
| producer.enabled | bool | `true` |  |
| producer.livenessProbe | object | `{"enabled":true,"failureThreshold":1,"initialDelaySeconds":120,"periodSeconds":60,"successThreshold":1,"timeoutSeconds":5}` | Configure extra options for Cardano producer containers' liveness and readiness probes ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes |
| producer.livenessProbe.enabled | bool | `true` | Enable livenessProbe on Cardano producer nodes |
| producer.livenessProbe.failureThreshold | int | `1` | Failure threshold for livenessProbe |
| producer.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| producer.livenessProbe.periodSeconds | int | `60` | Period seconds for livenessProbe |
| producer.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| producer.livenessProbe.timeoutSeconds | int | `5` | Timeout seconds for livenessProbe |
| producer.nodeAffinityPreset | object | `{"key":"","type":"","values":[]}` | Node master.affinity preset ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity |
| producer.nodeAffinityPreset.key | string | `""` | Node label key to match. Ignored if `master.affinity` is set |
| producer.nodeAffinityPreset.type | string | `""` | Node affinity preset type. Ignored if `master.affinity` is set. Allowed values: `soft` or `hard` |
| producer.nodeAffinityPreset.values | list | `[]` | Node label values to match. Ignored if `master.affinity` is set E.g. values:   - e2e-az1   - e2e-az2 |
| producer.nodeSelector | object | `{}` | master.nodeSelector Node labels for Cardano producer pods assignment ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| producer.podAffinityPreset | string | `""` | Pod affinity preset. Ignored if `master.affinity` is set. Allowed values: `soft` or `hard` ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity |
| producer.podAntiAffinityPreset | string | `"soft"` | Pod anti-affinity preset. Ignored if `master.affinity` is set. Allowed values: `soft` or `hard` ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity |
| producer.readinessProbe.enabled | bool | `true` | Enable readinessProbe on Cardano producer nodes |
| producer.readinessProbe.failureThreshold | int | `5` | Failure threshold for readinessProbe |
| producer.readinessProbe.initialDelaySeconds | int | `60` | Initial delay seconds for readinessProbe |
| producer.readinessProbe.periodSeconds | int | `60` | Period seconds for readinessProbe |
| producer.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| producer.readinessProbe.timeoutSeconds | int | `1` | Timeout seconds for readinessProbe |
| producer.replicaCount | int | `1` |  |
| producer.resources | object | `{"limits":{"cpu":"1","memory":"2048Mi"},"requests":{"cpu":"100m","memory":"512Mi"}}` | Cardano producer resource requests and limits ref: http://kubernetes.io/docs/user-guide/compute-resources/ |
| producer.resources.limits | object | `{"cpu":"1","memory":"2048Mi"}` | The resources limits for the Cardano producer containers |
| producer.resources.requests | object | `{"cpu":"100m","memory":"512Mi"}` | The requested resources for the Cardano producer containers |
| producer.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| producer.shareProcessNamespace | bool | `false` | Share a single process namespace between all of the containers in Cardano producer pods ref: https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/ |
| producer.spreadConstraints | object | `{}` | master.spreadConstraints Spread Constraints for Cardano producer pod assignment ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/ E.g. spreadConstraints:   - maxSkew: 1     topologyKey: node     whenUnsatisfiable: DoNotSchedule |
| producer.startupProbe.enabled | bool | `true` | Enable startupProbe on Cardano producer nodes ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes |
| producer.startupProbe.failureThreshold | int | `360` | Failure threshold for startupProbe |
| producer.startupProbe.initialDelaySeconds | int | `60` | Initial delay seconds for startupProbe |
| producer.startupProbe.periodSeconds | int | `60` | Period seconds for startupProbe |
| producer.startupProbe.successThreshold | int | `1` | Success threshold for startupProbe |
| producer.startupProbe.timeoutSeconds | int | `5` | Timeout seconds for startupProbe |
| producer.terminationGracePeriodSeconds | int | `30` | Integer setting the termination grace period for the cardano-producer pods |
| producer.tolerations | list | `[]` | master.tolerations Tolerations for Cardano producer pods assignment ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| redis.architecture | string | `"standalone"` | Single service exposed (redis-master) |
| redis.auth.existingSecret | string | `"{{ .Release.Name }}-auth"` | name of an existing secret that contains all of the required secrets |
| redis.master.persistence.enabled | bool | `false` |  |
| redis.networkPolicy.allowExternal | bool | `false` |  |
| redis.networkPolicy.enabled | bool | `true` |  |
| redis.replica.persistence.enabled | bool | `false` |  |
| redis.replica.replicaCount | int | `0` |  |
| relay.affinity | object | `{}` | Affinity for Cardano relay pods assignment ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity NOTE: `master.podAffinityPreset`, `master.podAntiAffinityPreset`, and `master.nodeAffinityPreset` will be ignored when it's set |
| relay.extraFlags | string | `"+RTS -c -RTS"` |  |
| relay.livenessProbe | object | `{"enabled":true,"failureThreshold":5,"initialDelaySeconds":900,"periodSeconds":60,"successThreshold":1,"timeoutSeconds":1}` | Configure extra options for Cardano relay containers' liveness and readiness probes |
| relay.livenessProbe.enabled | bool | `true` | Enable livenessProbe on Relay nodes ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes |
| relay.livenessProbe.failureThreshold | int | `5` | Failure threshold for livenessProbe |
| relay.livenessProbe.initialDelaySeconds | int | `900` | Initial delay seconds for livenessProbe |
| relay.livenessProbe.periodSeconds | int | `60` | Period seconds for livenessProbe |
| relay.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| relay.livenessProbe.timeoutSeconds | int | `1` | Timeout seconds for livenessProbe |
| relay.nodeAffinityPreset | object | `{"key":"","type":"","values":[]}` | Node master.affinity preset ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity |
| relay.nodeAffinityPreset.key | string | `""` | Node label key to match. Ignored if `master.affinity` is set |
| relay.nodeAffinityPreset.type | string | `""` | Node affinity preset type. Ignored if `master.affinity` is set. Allowed values: `soft` or `hard` |
| relay.nodeAffinityPreset.values | list | `[]` | Node label values to match. Ignored if `master.affinity` is set E.g. values:   - e2e-az1   - e2e-az2 |
| relay.nodeSelector | object | `{}` | Node labels for Cardano relay pods assignment ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| relay.podAffinityPreset | string | `""` | Pod affinity preset. Ignored if `master.affinity` is set. Allowed values: `soft` or `hard` ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity |
| relay.podAntiAffinityPreset | string | `"soft"` | Pod anti-affinity preset. Ignored if `master.affinity` is set. Allowed values: `soft` or `hard` ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity |
| relay.readinessProbe.enabled | bool | `true` |  |
| relay.readinessProbe.failureThreshold | int | `5` | Failure threshold for readinessProbe |
| relay.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| relay.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| relay.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| relay.readinessProbe.timeoutSeconds | int | `5` | Timeout seconds for readinessProbe |
| relay.replicaCount | int | `1` |  |
| relay.resources | object | `{"limits":{"cpu":"1","memory":"4096Mi"},"requests":{"cpu":"100m","memory":"512Mi"}}` | Cardano relay resource requests and limits ref: http://kubernetes.io/docs/user-guide/compute-resources/ |
| relay.resources.limits | object | `{"cpu":"1","memory":"4096Mi"}` | The resources limits for the Cardano relay containers |
| relay.resources.requests | object | `{"cpu":"100m","memory":"512Mi"}` | The requested resources for the Cardano relay containers |
| relay.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| relay.shareProcessNamespace | bool | `true` | Share a single process namespace between all of the containers in Cardano relay pods ref: https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/ |
| relay.spreadConstraints | object | `{}` | Spread Constraints for Cardano relay pod assignment ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/ E.g. spreadConstraints:   - maxSkew: 1     topologyKey: node     whenUnsatisfiable: DoNotSchedule |
| relay.startupProbe.enabled | bool | `true` | Enable startupProbe on Relay nodes ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes |
| relay.startupProbe.failureThreshold | int | `60` | Failure threshold for startupProbe failureThreshold * periodSeconds = 1 hour. |
| relay.startupProbe.initialDelaySeconds | int | `60` | Initial delay seconds for startupProbe |
| relay.startupProbe.periodSeconds | int | `60` | Period seconds for startupProbe |
| relay.startupProbe.successThreshold | int | `1` | Success threshold for startupProbe |
| relay.startupProbe.timeoutSeconds | int | `5` | Timeout seconds for startupProbe |
| relay.terminationGracePeriodSeconds | int | `30` | Integer setting the termination grace period for the cardano-relay pods |
| relay.tolerations | list | `[]` | Tolerations for Cardano relay pods assignment ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| service.annotations."service.beta.kubernetes.io/azure-dns-label-name" | string | `"stupidchess"` | Hostname to be assigned to the ELB for the service |
| service.port | int | `6000` |  |
| service.type | string | `"LoadBalancer"` |  |
| vault.csi.coldVaultName | string | `""` | Name of the Azure Key Vault that contains cold keys. Vault secrets are mounted read-only in the admin pod. |
| vault.csi.enabled | bool | `true` | Enable private key access from a Vault |
| vault.csi.hotVaultName | string | `""` | Name of the Azure Key Vault that contains hot keys. Vault secrets (kesSkey, vrfSkey, nodeCert) are mounted read-only in cardano-producer pod. |
| vault.csi.tenantId | string | `""` | Tenant ID containing the Azure Key Vault instance |
| vault.csi.userAssignedIdentityID | string | `""` | ClientId of the addon-created managed identity |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
