# Services

We've seen how to create deployments to manage pods however, the names and ip address of the pods is not know upfront and that can keep changing. How can we reach the pods when they can't addressed with a fixed name? Services solves that problem.

Let's create a deployment of figlet-web and create a service exposing that.

The `deployment.yaml` file:

```
$ cat deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: figlet-web
  labels:
    app: figlet-web
spec:
  replicas: 2
  selector:
    matchLabels:
        app: figlet-web
  template:
    metadata:
      labels:
        app: figlet-web
    spec:
      containers:
      - name: figlet-web
        image: anandology/figlet-web:green
```

The `service.yaml` file:

```
$ cat service.yaml
apiVersion: v1
kind: Service
metadata:
  name: figlet-web
spec:
  selector:
    app: figlet-web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

As you can see the service is defined by specifying a selector using labels.

Let's create the depoloyment and service.

```
$ kubectl apply -f deployment.yaml
deployment.apps/figlet-web configured
$ kubectl apply -f service.yaml
service/figlet-web created
```

Let's look at the services now.

```
$ kubectl  get services
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
figlet-web   ClusterIP   10.245.223.123   <none>        80/TCP    55s
```

As you can see the service has an internal IP address and that is going
to be the same even if the underlying pods change. The service will take care of load balancing between the available pods.

While the service got a fixed name and IP address it is still accessible only inside the cluster. You can try exec into a pod and try accessing it.

```
$ kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
figlet-web-f8b5cc5cd-l24rv   1/1     Running   0          3m11s
figlet-web-f8b5cc5cd-sp65l   1/1     Running   0          3m13s

$ kubectl exec -it figlet-web-f8b5cc5cd-l24rv -- bash
root@figlet-web-f8b5cc5cd-l24rv:/app# curl http://figlet-web/
<!DOCTYPE html>
<html lang="en">
...

# curl http://figlet-web.alpha.svc.cluster.local/
<!DOCTYPE html>
<html lang="en">
...

# curl http://10.245.223.123/
<!DOCTYPE html>
<html lang="en">
```

The service can be accessed using the service name, the fully qualified name of the service or its IP address.

## Port-Forwarding the service

We can port-forward a service to the temparily access it.

```
$ kubectl port-forward service/figlet-web --address 0.0.0.0 9090:80
Forwarding from 0.0.0.0:9090 -> 8080
```

## NodePort Service

By default the type of a service is `ClusterIP`, which gets an internal IP address. To make a service accessible to the outside world, we need to make it a `NodePort` service (or `LoadBalancer`).

The `NodePort` kind of service will have all of `ClusterIP`, plus the service will be accessible from an allocated port on all the worker nodes in the cluster.

Let's try changing the type of our service to `NodePort`.

```
$ cat service.yaml
apiVersion: v1
kind: Service
metadata:
  name: figlet-web
spec:
  type: NodePort
  selector:
    app: figlet-web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080

$ kubectl apply -f service.yaml
service/figlet-web configured
```

Let's look at the services now.

```
$ kubectl get services
NAME         TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
figlet-web   NodePort   10.245.223.123   <none>        80:30284/TCP   16m
```

As you can see the ports is specified as `80:30284`. The last part is the port on which the service is accessible from any of the worker nodes.

```
$ kubectl get nodes -o wide
NAME                 STATUS   ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP      OS-IMAGE                       KERNEL-VERSION         CONTAINER-RUNTIME
k8s-workshop-c3gva   Ready    <none>   23h   v1.22.7   10.139.32.102   143.110.178.18   Debian GNU/Linux 10 (buster)   5.10.0-0.bpo.9-amd64   containerd://1.4.12
k8s-workshop-c3gve   Ready    <none>   23h   v1.22.7   10.139.32.103   165.232.182.8    Debian GNU/Linux 10 (buster)   5.10.0-0.bpo.9-amd64   containerd://1.4.12
k8s-workshop-c3gvg   Ready    <none>   23h   v1.22.7   10.139.32.104   64.227.171.35    Debian GNU/Linux 10 (buster)   5.10.0-0.bpo.9-amd64   containerd://1.4.12
```

If you point you browser to `http://143.110.178.18:30284/`, you'll be able to access the service. That works for the external IP address of any of the nodes.

## Load Balancer

While a `NodePort` service is accessible to the outside world, it is doesn't have a fixed IP and we can't specify a fixed port like 80. The `LoadBalancer` type service solves that issue by creating a load balancer in the cloud, which would give a fixed IP or a domain name.

```
$ cat service.yaml
apiVersion: v1
kind: Service
metadata:
  name: figlet-web
spec:
  type: LoadBalancer
  selector:
    app: figlet-web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080

$ kubectl apply -f service.yaml
service/figlet-web configured
```

Let's look at the services.

```
$ kubectl get svc
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
figlet-web   LoadBalancer   10.245.223.123   <pending>     80:30284/TCP   36m
```

As you can see the External-IP is pending. It is because, kubernetes is trying to create a load balancer by contacting the cloud provider (digitalocean in this case) and that is going to take some time. After sometime, we'll get an external IP address to access the node.

```
$ kubectl get svc
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)        AGE
figlet-web   LoadBalancer   10.245.223.123   64.225.85.151   80:30284/TCP   39m
```

A load balancer is an expensive resource and it may not be good idea to create a load balancer for every application. The common way to address that is by using an ingress controller. We'll learn about it in the next lesson.

## Exercise: Deploy graphviz-web

Deploy graphviz-web and graphviz-api as NodePort services.
