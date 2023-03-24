FROM azul/zulu-openjdk-debian:11

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

USER root

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install --no-install-recommends -y curl

ARG SDK_VERSION
ARG DAML_SERVICE
ENV DAML_SERVICE=$DAML_SERVICE
COPY ./entrypoint.sh /opt/entrypoint.sh
ADD https://github.com/digital-asset/daml/releases/download/v${SDK_VERSION}/${DAML_SERVICE}-${SDK_VERSION}.jar /opt/service.jar

ENTRYPOINT ["/opt/entrypoint.sh"]
