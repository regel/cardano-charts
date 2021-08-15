FROM mcr.microsoft.com/azure-cli

USER 0
RUN az aks install-cli && \
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    USE_SUDO=false ./get_helm.sh && \
    helm version

RUN apk update && apk add bind-tools gettext apache2-utils  # dig,envsubst,htpasswd required by install.sh

RUN curl -sL https://github.com/vmware-tanzu/velero/releases/download/v1.6.0/velero-v1.6.0-linux-amd64.tar.gz | tar -xz && \
    chmod 700 velero-v1.6.0-linux-amd64/velero && \
    mv velero-v1.6.0-linux-amd64/velero /usr/local/bin

WORKDIR /app

RUN chgrp -R 0 /usr/local/bin && chmod -R g=u /usr/local/bin
RUN mkdir /app/.azure && \
    chgrp -R 0 /app && chmod -R g=u /app

USER 1001
ENV HOME /app

RUN helm repo add stable https://charts.helm.sh/stable && \
    helm repo add bitnami https://charts.bitnami.com/bitnami && \
    helm repo add jetstack https://charts.jetstack.io && \
    helm repo update

# change shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

LABEL maintainer="<sebastien.regel@gmail.com>"
