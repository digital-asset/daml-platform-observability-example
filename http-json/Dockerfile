FROM azul/zulu-openjdk-debian:11

USER root

ARG SDK_VERSION
COPY ./entrypoint.sh /opt/entrypoint.sh
ADD https://github.com/digital-asset/daml/releases/download/v${SDK_VERSION}/http-json-${SDK_VERSION}.jar /opt/http-json.jar

ENTRYPOINT ["/opt/entrypoint.sh"]
