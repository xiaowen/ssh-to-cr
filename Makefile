PROJECT_ID?=tensile-howl-307302
REGION?=us-central1
SERVICE_HOSTNAME?=ssh-server-yhp4zujfia-uc.a.run.app

docker-server:
	cp ${HOME}/.ssh/authorized_keys server/
	docker build -t gcr.io/${PROJECT_ID}/ssh-server server
	docker push gcr.io/${PROJECT_ID}/ssh-server

docker-client:
	docker build --build-arg cloud_run_service_hostname=${SERVICE_HOSTNAME} -t gcr.io/${PROJECT_ID}/ssh-client client
	#docker push gcr.io/${PROJECT_ID}/ssh-client

deploy:
	gcloud alpha run deploy ssh-server \
	    --image gcr.io/${PROJECT_ID}/ssh-server \
	    --region ${REGION} \
	    --allow-unauthenticated \
	    --use-http2 \
	    --port=8022 \
	    --timeout=3600 \
	    --min-instances=1 \
	    --max-instances=1 \
	    --sandbox=minivm \
	    --project ${PROJECT_ID}

deploy-gke:
	kubectl delete deployment ssh-server
	kubectl create deployment ssh-server --image=gcr.io/${PROJECT_ID}/ssh-server

shell:
	docker run --rm -it -v ${HOME}/.ssh:/app/.ssh -p 8022:8022 -p 8080:8080 gcr.io/${PROJECT_ID}/ssh-client

shell-gke:
	kubectl exec -it $$(kubectl get pods -l=app=ssh-server -o jsonpath='{.items[*].metadata.name}') -- /bin/bash
