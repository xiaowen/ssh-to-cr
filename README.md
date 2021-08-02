This shows an example that does the following:
1. Run an Envoy proxy in Cloud Run fronting a web app.
2. Tunnel an SSH session over HTTP/2, i.e. you can ssh into a Cloud Run instance.
3. You can use that SSH session to forward other ports.
4. All other HTTP traffic is served directly by the web app.

Some ideas borrowed from:
* https://github.com/wlhee/mtls-on-cloud-run-demo
* https://github.com/costinm/krun/tree/main/samples/cloudrun
* https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/http/upgrades#tunneling-tcp-over-http
* https://stackoverflow.com/questions/65897760/how-to-disable-route-timeout-in-envoy

Known issues:
* ctrl-c doesn't work in the ssh session
* sudo doesn't work in the ssh session
* Tested on both a Macbook and a Linux Google Compute Engine VM as clients.  On the GCE VM, had to rebuild the container image on that VM to get it working.
* Currently, this requires setting Cloud Run ingress to allow all traffic.
