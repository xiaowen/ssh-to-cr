#!/bin/sh

echo "Starting SSH server ..."
service ssh start

echo "Starting web server"
su - appuser -c 'python3 -m http.server --bind 0.0.0.0 8080' &

echo "Starting Envoy ..."
/app/envoy -c /etc/envoy/server-envoy.yaml
