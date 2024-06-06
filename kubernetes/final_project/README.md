# Kubernetes

In this final task, we’ll migrate a project from docker-compose to Kubernetes. With provided docker-compose.yaml you have to create all necessary specifications for Kubernetes deployment.

## Requirements

1. Every single application in this project has to have at least one Service. ✅

2. Elasticsearch is a single clustered application. ✅

3. Elasticsearch should be deployed as a StatefulSet, Persistent Volumes would be a plus. ✅

4. All communications have to be implemented through Services. ✅

5. Kibana and web-server have to be accessible from outside of the cluster. ✅

6. All shared configs should be managed from one place. ✅

7. In Kubernetes specifications you should use as many different kinds of Kubernetes objects as possible. ✅

## Notes

On local kubernetes installations you might need to extend available memory, due to Elasticsearch requirements.
This docker-compose.yaml require some indentation fixes due to GridU UI specifics.

# Implementation steps

## Prerequisites

1. Enable ingress controller ([for Docker Desktop](https://kubernetes.github.io/ingress-nginx/deploy/#quick-start)):

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.5/deploy/static/provider/cloud/deploy.yaml
```

2. Install [Elastic Cloud custom resource definitions](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) and the operator with its RBAC rules:

```bash
kubectl create -f https://download.elastic.co/downloads/eck/1.8.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/1.8.0/operator.yaml
```

## Deployment

1. Elasticsearch cluster using [ECK guide](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-eck.html):

```bash
# apply manifest (creates StatefulSet for Elasticsearch and ClusterIp services for both E&K)
kubectl apply -f eck/elasticsearch-kibana.yml
```

```bash
# check Elasticsearch

# check pods health
kubectl get elasticsearch
kubectl get pods --selector='elasticsearch.k8s.elastic.co/cluster-name=quickstart'
# check if ClusterIp is on place
kubectl get service quickstart-es-http
# get the credentials
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
# request the Elasticsearch endpoint
kubectl port-forward service/quickstart-es-http 9200
# request localhost in a separate tab (-k disables certificate verification and should be used for testing purposes only!)
curl -u "elastic:$PASSWORD" -k "https://localhost:9200"
```

```bash
# check Kibana

# check pods health
kubectl get kibana
kubectl get pod --selector='kibana.k8s.elastic.co/name=quickstart'
# check if ClusterIp is on place
kubectl get service quickstart-kb-http
# elastic user password can be obtained with the following command:
kubectl get secret quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo
# open the Kibana endpoint
kubectl port-forward service/quickstart-kb-http 5601

# also, Kibana will be accessible by
http://localhost:$CLUSTER_IP_PORT
```

2. Redis cluster

```bash
# apply manifest
kubectl apply -f redis.yml

# check configmap
kubectl describe configmap/app-config

# check if slave pod works and knows master host
kubectl exec -it redis-slave-pod -- redis-cli
127.0.0.1:6379> CONFIG GET slaveof
```

3. web server

```bash
# apply manifest
kubectl apply -f web-server.yml

# list the Pod's container environment variables
kubectl exec web-app-pod -- printenv

# the web server is accessible by
https://localhost/getTaskAnswer
```
