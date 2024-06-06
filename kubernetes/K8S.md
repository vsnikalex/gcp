# Career::T2::Kubernetes

## `kubectl` syntax
```bash
kubectl [command] [TYPE] [NAME] [flags]
```

## K8S control plane
Is a bunch of masters (system operations nodes).
It is important to have a multi-master control plane to ensure high availability of a K8S cluster.
Uses leader election pattern (leader master node controls the other ones).

## kube-apiserver
* Front-end to the control plane
* Exposes the API (REST)
* Consumes JSON/YAML

## Cluster Store
* Persists cluster state and config
* Based on `etcd`

## Kube-controller-manager
* Controller of controllers
  * Node controller
  * Deployment controller...
* Watch loops
* Reconciles observed state with desired state

## Kube-scheduler
* Watches API server for new work tasks
* Assigns work to cluster nodes

## Kubelet
* Registeres node with cluster.
* Watches API Server for work tasks (Pods)
* Excecutes Pods
* Reports back to masters

## Container runtime
Can be Docker: starts and stops containers.

## Kube-proxy
* Assigns unique IPs to pods
* Basic load balancing

## Watch pods updates
```bash
kubectl get pods --watch
```

## Apply pod manifest
```bash
kubectl apply -f multi-pod.yml
```

## Expose pod
```bash
kubectl expose pod hello-pod --name=hello-svc --target-port=8080 --type=NodePort
```

## Dry run configmap
```bash
kubectl create configmap --from-file=files/redis.conf redis-slave --dry-run -o yaml
```

## Create configmap from literal
```bash
kubectl create configmap --from-literal=PORT_WE_WANT=6469 env-config --dry-run -o yaml
```

## Dry run secret from literal
```bash
kubectl create secret generic env-secret --from-literal GRIDU_SECRET_ENV=KUBERNETES_IS_VERY_SECURE --dry-run=client -o yaml
```

