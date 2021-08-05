# How to SSH into your Cloud Run instance
This is an example that shows how to include an SSH server in your [Cloud Run](https://cloud.google.com/run) instance, which you can use to debug your web app.  You can also use it to run interactive tools like the Django shell and the Interactive Ruby shell.

**This should only be used during development or for a debug service.  You should not include SSH servers in your production workload!**

# How does it work?
Cloud Run does not expose TCP directly to container instances.  Therefore, you'll need to tunnel TCP over HTTP/2, which can be accomplished by running an [Envoy](https://www.envoyproxy.io/) proxy on both the client and the server.

The server-side Envoy proxy is configured to transparently pass web traffic directly to the web app and only intercept the SSH traffic.

# Prerequisites
1. Sign up for Google Cloud and [create a project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) if you don't already have one.
2. Have access to a terminal on a Macbook or Linux machine.  You can also use [Google Cloud Shell](https://cloud.google.com/shell).
3. Make sure that the [Google Cloud SDK](https://cloud.google.com/sdk) and [Docker](https://docs.docker.com/get-docker/) are installed.  (These are already installed on Cloud Shell.)
4. Configure the `gcloud` and `docker` command line tools to be able to authenticate to your Google Cloud project.
5. Make sure to have an SSH keypair.  If you don't have one, run `ssh-keygen`.  Put your public key into `~/.ssh/authorized_keys` (e.g. `cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys`).  This file will be copied into the container running the SSH server so it can be used to authenticate you.
6. Have ports 8022 and 8080 available as those will be proxied from the remote server.

# Instructions
Set a couple of environment variables according to your environment.  You can get your project ID by running `gcloud projects list`.

```
export REGION=<your preferred region, such as us-central1>
export PROJECT_ID=<your project ID>
```

Then deploy a test app to Cloud Run:
```
gcloud run deploy ssh-server \
    --image us-docker.pkg.dev/cloudrun/container/hello \
    --allow-unauthenticated \
    --region ${REGION} \
    --project ${PROJECT_ID}
```

Get the URL of that test app by running:
```
gcloud run services list --region ${REGION} --project ${PROJECT_ID}
```

Remove the URL scheme, then put it into an environment variable.  I.e. use `ssh-server-hash-uw.a.run.app` instead of `https://ssh-server-hash-uw.a.run.app`:

```
export SERVICE_HOSTNAME=<the hostname without the https:// in front>
```

Check out this repository if you haven't done so (e.g. `git clone https://github.com/xiaowen/ssh-to-cr`) and switch to that directory.

Run the following to build the server container:
```
make docker-server
```

Deploy the server:
```
make deploy
```

Build the client:
```
make docker-client
```

Now you can SSH into the client:
```
make shell
```

This runs the client container under the hood and proxies ports 8022 and 8080 to localhost.  You can now use port 8022 to open another SSH connection to the server:
```
ssh -p 8022 appuser@localhost
```

You can also access the example web server locally:
```
curl localhost:8080
```

Or access the example web server via its canonical Cloud Run URL:
```
curl https://${SERVICE_HOSTNAME}
```

# Acknowledgements
Some ideas borrowed from:
* https://github.com/wlhee/mtls-on-cloud-run-demo
* https://github.com/costinm/krun/tree/main/samples/cloudrun
* https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/http/upgrades#tunneling-tcp-over-http
* https://stackoverflow.com/questions/65897760/how-to-disable-route-timeout-in-envoy

# Known issues
* Currently, this requires setting Cloud Run ingress to allow all traffic.
* Must use --sandbox=minivm to use sudo in the ssh session
* Tested on both a Macbook and a Linux Google Compute Engine VM as clients.  On the GCE VM, had to rebuild the container image on that VM to get it working.
