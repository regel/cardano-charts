# Cardano Charts

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Contains Helm Charts for operating **the most secure** Cardano nodes in Kubernetes:
- [cardano](./cardano/README.md)

## Backers :dart: :heart_eyes:

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/gh-regel#backer)]

<a href="https://opencollective.com/gh-regel#backers" target="_blank"><img src="https://opencollective.com/gh-regel/backers.svg?width=890"></a>

## Sponsors :whale:

Support this project by becoming a sponsor. Your logo will show up here with a
link to your website. [[Become a
sponsor](https://opencollective.com/gh-regel#sponsor)]

## Donations in ADA :gem:

Cardano hodlers can send donations to this wallet address: `addr1q973kf48y9vxqareqvxr7flacx3pl3rz0m9lmwt4nej0zr99dw6mre74f2g48nntw5ar6mz58fm09sk70e0k4vgmkess27g47n`

### No Donations :gift: :neutral_face:

Like :100: this repo and send this message on Twitter: I :hearts: u Charles

## Security Measures Every Stake Pool Operator Should Implement

Refer to the Cardano forum [guide](https://forum.cardano.org/t/back-to-basics-security-measures-every-cardano-stake-pool-operators-should-know-and-implement/38166) for keys and secrets management.

### How This Cardano Helm Chart Implements Security Guidelines

This Cloud Native Helm Chart leverages advanced security features provided in Kubernetes and Cloud vendors extensions. :rotating_light: Ensure that you understand these concepts before using this Chart:

- [Calico](https://docs.microsoft.com/en-us/azure/aks/use-network-policies) plugin: this network plugin in Kubernetes enforces `ingress` and `egress` traffic between pods and external IPs using [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) 
- Key Vault: all secret keys required to run a Cardano node are stored inside a Vault and only mounted where the least access priviledge applies. The Azure Vault used in this Chart requires the configuration of a [User Assigned Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
- Run As NonRoot: Containers run using non-root users according to best Docker practices

### Concepts

#### Cold (Offline) Keys :snowman:

Your cold keys are essentially your pool id. When you submit registration with the same cold keys you are updating the pool parameters rather than creating a new one.

- `Cold skey`: Stake pool cold (offline) key
- `Cold vkey`: Stake pool cold vkey
- `Cold counter`: Stake pool cold counter

Using this Cardano Helm Chart, the cold keys are automatically read from the vault and mounted read-only in the admin's pod filesystem. The admin pod is using air gapping for security reasons and will not be able to communicate with other pods in this Chart. Use the admin pod for transactions signing and nothing else.

#### Hot Keys :volcano:

- `KES skey`: Also called  "hot" key, is a node operational key that authenticates who you are. You specify the validity of the KES key using the start time and key period parameters and this KES key needs to be updated every 90 days. 
- `VRF skey`: Controls your participation in the slot leader selection process. 
- `Operational node certificate`:  Represent the link between the operator's offline key and their operational key. A certificate's job is to check whether or not an operational key is valid, to prevent malicious interference. The certificate identifies the current operational key, and is signed by the offline key. 

With this Cardano Helm Chart, the hot keys are automatically read from the vault and mounted in the producer's filesystem.

##### Updating Hot Keys

Updating the KES hot key in the Vault will not be reflected in the producer's pod. Therefore, delete the producer pod manually, or scale the StatefulSet in order to restart the pod and read the updated hot keys from the Vault: 

```
kubectl scale -n cardano-ns --replicas=0 sts/cardano-producer
kubectl scale -n cardano-ns --replicas=1 sts/cardano-producer
```

## Frequently Asked Questions :question:

### How can Cardano Charts be so Awesome?

Open Source is Awesome but is hard. Help me grow this project by becoming a backer and making a [[donation](https://opencollective.com/gh-regel#backer)]

### Where Can I Find Documentation on Azure Key Vault?

Here: [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/basic-concepts)

### Storing Cold Keys in Luna HSM when Using Azure Key Vault? 

[Microsoft](https://azure.microsoft.com/): [[Become a sponsor](https://opencollective.com/gh-regel#sponsor)]

To use Azure HSM for key storage and signature, two things must happen first:

- Azure Key Vault must add support for the [ed25519](https://fr.wikipedia.org/wiki/Curve25519) crypto algorithm used in Cardano. At this time, the current generation of managed HSM hardware does not seem to support it yet
- `cardano-cli` or another tool must be able to sign Tx raw transactions using the Azure Key Vault [REST API](https://docs.microsoft.com/en-us/rest/api/keyvault/)

### Where Can I Find Documentation on Network Policies?

[Tigera](https://tigera.io): [[Become a sponsor](https://opencollective.com/gh-regel#sponsor)]

Tigera web site is a good place to start reading about [Calico](https://docs.projectcalico.org/reference/public-cloud/azure). Also, check their [Definitive guide to container networking, security, and troubleshooting](https://www.tigera.io/lp/calico-open-source-white-paper/)

### Can You Add Support For Other Vaults And Other Cloud Vendors?

See [CONTRIBUTING](./CONTRIBUTING.md).

### Where To File Issues?

If you are a vulnerability reporter (for example, a security researcher) who would like report a vulnerability, first contact me privately via the Telegram link below.

Other issues can be reported on Github.

### How to Contact?

Chat :speech_balloon: with me on [Telegram](https://t.me/ghregel)

### Want to Offer A Dream Job? :necktie:

You know the saying, anything is possible. Just know that I am in Geneva, CH, and therefore I have high expectations. :four_leaf_clover:

## Documentation

The README documentation is generated by [helm-docs](https://github.com/norwoodj/helm-docs)

### Setup in Azure

1. Create a new resource group in Azure
1. Create a Kubernetes cluster and enable Calico plugin during the initial setup
1. Create a new Azure Key Vault. Choose `Private endpoint` and select the vnet of the above Kubernetes cluster
1. Create a User Assigned Managed Identity: `az identity create -g resourcegroup -n id0`
1. Find the VMSS of the Kubernetes cluster: `az vmss list -o table`
1. Assign the identity to the VMSS: `az vmss identity assign`
1. Assign Access Policies `Get` for Key Permissions and Secret Permissions to the User Assigned Managed Identity
1. Install the Helm Chart `csi-secrets-store-provider-azure` in the Kubernetes cluster
1. Write Cold keys in the Vault: `coldSkey`, `coldVkey`, `coldCounter`
1. Write Hot Keys in the Vault: `kesSkey`, `vrfSkey`, `nodeCert`

#### Running this Chart :rocket:

Install the Azure Key Vault provider:

```
helm repo add https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts
helm install csi-secrets-store-provider-azure/csi-secrets-store-provider-azure --generate-name --set secrets-store-csi-driver.syncSecret.enabled=true --namespace kube-system
```

Installing this Chart:

```
helm upgrade --install pool \
  --namespace testnet \
  --values cardano/values.yaml \
  --set secrets.redisUsername=cardano \
  --set secrets.redisPassword=CHANGEME \
  --set redis.auth.username=cardano \
  --set redis.auth.password=CHANGEME \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true \
  --set metrics.serviceMonitor.namespace=prometheus \
  --set vault.csi.enabled=true \
  --set vault.csi.coldVaultName=myVaultName \
  --set vault.csi.hotVaultName=myVaultName \
  --set vault.csi.userAssignedIdentityID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
  --set vault.csi.tenantId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
    ./cardano
```

