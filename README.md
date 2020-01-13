# Elasticsearch infrastructure

The elasticsearch infrastructure is based on the official [HELM chart](https://github.com/elastic/helm-charts) from 3. January 2020.

## Create new docker image with elasticsearch

The docker image is built in the CI and the elasticsearch version is specified in the Dockerfile & Jenkinsfile (both have to be modified).
_Please remember that creating the docker image with the same image name and tag will most likely not install correct image because the downloaded images are cached and therefore the old image will be used._

If you create a new docker image you have to modify image tag in `/deploy/*.yml` files.

To build the image manually (e.g.: for testing) run:
```bash
docker build -t erento_elastic_search .
```

## How to proceed to install elastic from scratch

If you didn't create a docker image yet, do it first.

First you need to create a StorageClass to be able to claim a volume with SSD type. Please run: (this has to be executed only once)
```bash
kubectl apply -f deploy/storage-class.yml
```

Add helm repo
```bash
helm repo add elastic https://helm.elastic.co
```

To install elasticsearch using helm follow these steps (can be applied at the same time):
```bash
helm install --name elasticsearch-master --values deploy/master.yml elastic/elasticsearch
helm install --name elasticsearch-data --values deploy/data.yml elastic/elasticsearch
helm install --name elasticsearch-client --values deploy/client.yml elastic/elasticsearch
```

## Where to get new dictionaries
Download new oxt file from [Language support of LibreOffice](https://wiki.documentfoundation.org/Language_support_of_LibreOffice) and unzip the file.

Afterwards replace or add `xx_XX.dic` and `xx_XX.aff` in `/hunspell/xx_XX/` and recreate docker image.

## Test
Create a new cluster:
```bash
export ZONE=europe-west1-b
export CLUSTER=elasticsearch-cluster
export MACHINE_TYPE=n1-standard-4
export K8S_VERSION=1.14.9-gke.2
gcloud container clusters create "$CLUSTER" --zone "$ZONE" --metadata disable-legacy-endpoints=true --enable-ip-alias --max-pods-per-node 20 --cluster-version "$K8S_VERSION" --disk-type pd-ssd --enable-autoupgrade --enable-stackdriver-kubernetes --image-type COS --machine-type "$MACHINE_TYPE" --node-version "$K8S_VERSION" --preemptible
```

_Note: FOR PRODUCTION USE --region europe-west1 to have regional cluster_

and install Helm:

```bash
helm init --history-max 200
```

Wait until the tiller pod is running and add the service account:
```bash
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```

Add application CRD:
```bash
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

Do not forget to clean up after testing by running:
```bash
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```

For testing, it is better to uncomment a `LoadBalancer` in the `./deploy/client.yml` to get a public IP address for communication with elasticsearch.

## Known issues:
- While using synonyms we cannot use `german_stop` filter due to [issue in Lucene](https://issues.apache.org/jira/browse/LUCENE-8137) & [closed ticket on elasticsearch](https://github.com/elastic/elasticsearch/issues/28838)
