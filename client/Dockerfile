FROM envoyproxy/envoy:v1.18.2 AS envoy-base

FROM debian:8 AS debian
RUN apt-get update \
    && apt-get -y install bash netcat openssh-client sudo telnet vim \
    && apt-get clean \
    && printf '%%appuser ALL=(ALL:ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/appuser

COPY client-envoy.yaml /etc/envoy/client-envoy.yaml
ARG cloud_run_service_hostname
RUN sed -i "s|CLOUD_RUN_SERVICE_HOSTNAME|${cloud_run_service_hostname}|g" /etc/envoy/client-envoy.yaml

WORKDIR /app
RUN useradd -G sudo appuser -d /app -s /bin/bash \
    && chown -R appuser /app \
    && chown appuser -R /app
USER appuser

COPY --from=envoy-base /usr/local/bin/envoy ./
COPY init.sh ./

CMD ["/app/init.sh"]
