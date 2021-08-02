#!/bin/sh

echo "Starting Envoy ..."
./envoy -c /etc/envoy/client-envoy.yaml &

echo "Waiting for Envoy to be ready ..."
nc -zv 127.0.0.1 8022
while [ $? -ne 0 ]
do
  echo "Envoy is not ready yet ..."
  sleep 0.2
  nc -zv 127.0.0.1 8022
done
echo "Envoy is ready"

echo "Starting SSH client ..."
ssh appuser@localhost -p 8022
