FROM envoyproxy/envoy:v1.18.2 AS envoy-base

FROM debian:8 AS debian
RUN apt-get update \
    && apt-get -y install bash netcat openssh-server sudo telnet vim \
    && apt-get clean \
    && printf '%%appuser ALL=(ALL:ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/appuser

WORKDIR /app

RUN useradd -G sudo appuser -d /app -s /bin/bash \
    && chown -R appuser /app \
    && mkdir /app/.ssh
COPY authorized_keys /app/.ssh/authorized_keys
COPY ssh_config /app/.ssh/config
RUN chown appuser -R /app \
    && chmod 644 /app/.ssh/authorized_keys

#USER appuser


COPY --from=envoy-base /usr/local/bin/envoy /app/envoy
COPY server-envoy.yaml /etc/envoy/server-envoy.yaml
COPY init.sh /app/
EXPOSE 8000

CMD ["/app/init.sh"]
