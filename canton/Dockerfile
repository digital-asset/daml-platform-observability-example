ARG CANTON_IMAGE
ARG CANTON_VERSION
FROM ${CANTON_IMAGE}:${CANTON_VERSION}

# Set default shell (for healthcheck commands)
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

USER root

# We are adding grpcurl and jq to perform gRPC healthchecks with Docker Compose
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install --no-install-recommends -y curl jq \
 && curl -fsSLO https://github.com/fullstorydev/grpcurl/releases/download/v1.8.7/grpcurl_1.8.7_linux_x86_64.tar.gz \
 && curl -fsSLO https://github.com/fullstorydev/grpcurl/releases/download/v1.8.7/grpcurl_1.8.7_checksums.txt \
 && sha256sum --check --ignore-missing grpcurl_1.8.7_checksums.txt \
 && tar -xvf grpcurl_1.8.7_linux_x86_64.tar.gz -C /usr/local/bin --totals grpcurl \
 && rm grpcurl_1.8.7*
