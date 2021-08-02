#!/bin/sh

echo "Starting SSH server ..."
service ssh start

echo "Starting Envoy ..."
/app/envoy -c /etc/envoy/server-envoy.yaml
