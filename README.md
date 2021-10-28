# Elasticsearch infrastructure

The elasticsearch infrastructure is based on the official [HELM chart](https://github.com/elastic/helm-charts) from 7. October 2021 and elasticsearch version `7.15.0`.

HELM is required in the version 3.

## How to proceed to install elastic from scratch

If you didn't:
- create a docker image yet, [do it first](#create-new-docker-image-with-elasticsearch).
- configure HELM yet, [do it first](#test).
- configure kubernetes cluster, [do it first](#test).

After setting up previous steps you need to create a `StorageClass` to be able to claim a volume with the SSD type. Please run: (this has to be executed only once on the new cluster)
```bash
kubectl apply -f deploy/storage-class.yml
```

Add helm repo
```bash
helm repo add elastic https://helm.elastic.co
```

To install elasticsearch using helm follow these steps (can be applied at the same time, the order is not important):
```bash
helm install elasticsearch-master -f deploy/master.yml elastic/elasticsearch --version 7.15.0
helm install elasticsearch-data -f deploy/data.yml elastic/elasticsearch --version 7.15.0
helm install elasticsearch-client -f deploy/client.yml elastic/elasticsearch --version 7.15.0
```
**Note:** When changing `master.yml`, `data.yml`, `client.yml` the easiest way to update is to use `helm upgrade` instead with the same parameters
as above. To finally apply the changes the respective running pods have to be restarted one after another.

## Create new docker image with elasticsearch

The docker image is built in the CI and pushed to `campanda-docker` container registry. The docker image version is specified in the Dockerfile & Jenkinsfile (both have to be updated after upgrade).
_Please remember that creating the docker image with the same image name and tag will most likely not install correct image because the downloaded images are cached and therefore the old image will be used._

If you create a new docker image you have to modify the image tag in `/deploy/*.yml` files.

To build the image manually (e.g.: for testing locally) run:
```bash
docker build -t campanda_elastic_search .
```
To push to the registry manually run:
```bash
docker build . -t eu.gcr.io/campanda-docker/infra-elasticsearch:7.15.0-campanda-XXX
docker push eu.gcr.io/campanda-docker/infra-elasticsearch:7.15.0-campanda-XXX
```
**Note:** replace `XXX` with a sequential number (first tag is `7.15.0-001`). 
Check the [container registry](https://console.cloud.google.com/gcr/images/campanda-docker/eu/infra-elasticsearch?project=campanda-docker) for latest number.

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

Do not forget to clean up after testing by running:
```bash
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```

For testing, it is better to uncomment a `LoadBalancer` in the `./deploy/client.yml` to get a public IP address for communication with elasticsearch.

## Where to get new dictionaries
Download new oxt file from [Language support of LibreOffice](https://wiki.documentfoundation.org/Language_support_of_LibreOffice) and unzip the file.

Afterwards replace or add `xx_XX.dic` and `xx_XX.aff` in `/hunspell/xx_XX/` and recreate docker image.

## Known issues:
- While using synonyms we cannot use `german_stop` filter due to [issue in Lucene](https://issues.apache.org/jira/browse/LUCENE-8137) & [closed ticket on elasticsearch](https://github.com/elastic/elasticsearch/issues/28838).
- Every pod emits a message: `OpenJDK 64-Bit Server VM warning: Option UseConcMarkSweepGC was deprecated in version 9.0 and will likely be removed in a future release.` this is due to GC in Java 9. After elastic upgrades their default image to Java 10 we can use a new GC which is not based on this deprecated option, [see more](https://github.com/elastic/elasticsearch/issues/36828#issuecomment-448564460).

## Troubleshooting

- When the elasticsearch pods are down, look at the following [post mortem report](https://erento.atlassian.net/wiki/spaces/dev/pages/963674119/2020-03-03+-+frontend+not+serving+any+content+due+to+elasticsearch+issue).

## How to use our elastic outside campanda

- Please, fork our repository. It will help us to follow your changes and give you a possibility to pull any future upgrades we will provide over time.
- Change `dictionaries/synonyms.txt` to be aligned with your business.
- Create your own docker image based on `Dockerfile` or use the default one if you don't need any plugins, synonyms or hunspell. _(You cannot use our docker image because it is published to the private container registry.)_
- Change `image` & `imageTag` in the `deploy/*.yml` files to your docker image.
- You will have to remove or change `imagePullSecrets` in `deploy/*.yml`. It is used to be authorized to pull the docker image from the private registry.
