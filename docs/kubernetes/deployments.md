# Replica Sets & Deployments

In the previous lesson, we saw how to create a pod. Creating a pod by hand is not something desirable because if the machine goes down, the pod will go down with it. To handle such issues, we create a ReplicaSet, specifying the number of replicas for the pod to be running.

## Listing ReplicaSets

```
$ kubectl get replicasets
No resources found in alpha namespace.
```

We could also use the short form `rs` to list replica sets.

```
$ kubectl get rs
No resources found in alpha namespace.
```

## Creating a Replica Set

```
$ cat rs.yaml
apiVersion: apps/v1
kind: ReplicaSet
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
        image: anandology/figlet-web
```

Let's apply it.

```
$ kubectl apply -f rs.yaml
replicaset.apps/figlet-web created
```

Lets look at the pods.

```
$ kubectl get pods
NAME               READY   STATUS              RESTARTS      AGE
figlet-web-blp4g   0/1     ContainerCreating   0             3s
figlet-web-m5blk   0/1     ContainerCreating   0             4s
```

As you can see it started creating two pods. Typically, multiple pods of a replica set will be scheduled on different nodes for high avaiability.

```
$ kubectl  get pods -o wide
NAME               READY   STATUS    RESTARTS   AGE   IP             NODE                 NOMINATED NODE   READINESS GATES
figlet-web-m5blk   1/1     Running   0          95s   10.244.1.87    k8s-workshop-c3gve   <none>           <none>
figlet-web-rg2ng   1/1     Running   0          75s   10.244.1.221   k8s-workshop-c3gvg   <none>           <none
```

The Replication Controller will make sure there are always 2 instances of the pods running. If pod becomes unavailable for reasons like a node going down or a node getting disconnected, it will schedule a new pod. If the disconnected node comes back and there are more than 2 pods running, it will delete the additional ones.

## Tweaking Replica Sets

Let's see what happens if we delete a pod.

```
$ kubectl get pods
NAME               READY   STATUS    RESTARTS   AGE
figlet-web-m5blk   1/1     Running   0          15m
figlet-web-rg2ng   1/1     Running   0          15m
```

Let's delete one of them.

```
$ kubectl delete pod figlet-web-m5blk
pod "figlet-web-m5blk" deleted
```

How many pods will be there now?

```
$ kubectl get pods
NAME               READY   STATUS              RESTARTS   AGE
figlet-web-kc2ls   0/1     ContainerCreating   0          2s
figlet-web-rg2ng   1/1     Running             0          16m
```

As you can see, the replication controller kicked in and created a new pod.

## Labels

You may have noticed that we've specified label in the metadata of
the pod template and also in `selector` field.

Let's look at the pods and their labels.

```
$ kubectl  get pods --show-labels
NAME               READY   STATUS    RESTARTS   AGE     LABELS
figlet-web-kc2ls   1/1     Running   0          4m42s   app=figlet-web
figlet-web-rg2ng   1/1     Running   0          20m     app=figlet-web
```

The replicaset watches the pods matching the labels specified in `selector`.

We can change the label of a pod and replicaset will think that a pod is mising and create a new pod.

This is a good way to take a faulty pod out of production and coninue troubleshooting it.

```
$ kubectl label --overwrite pod figlet-web-kc2ls app=figlet-web-faulty
pod/figlet-web-kc2ls labeled
```

Let's look at the pods now.

```
$ kubectl  get pods --show-labels
NAME               READY   STATUS    RESTARTS   AGE     LABELS
figlet-web-cvsw8   1/1     Running   0          7s      app=figlet-web
figlet-web-kc2ls   1/1     Running   0          7m49s   app=figlet-web-faulty
figlet-web-rg2ng   1/1     Running   0          24m     app=figlet-web
```

As you can see a new pod is created as the replication controller noticed that one pod is missing.

## Deployments

One of the issues with replica sets is that it will not create new pods when you change the template of the container like changing the image to a new version because the it is satified with the number of pods matching the selector.

We use deployments to take care of this.

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

Let's apply the deployment.

```
$ kubectl apply -f deployment.yaml
deployment.apps/figlet-web created
```

The deployment will create a replica set.

```
$ kubectl get rs
NAME                   DESIRED   CURRENT   READY   AGE
figlet-web-f8b5cc5cd   2         2         2       45s
```

And the replicaset will create pods.

```
$ kubectl get pods --show-labels
NAME                         READY   STATUS    RESTARTS   AGE   LABELS
figlet-web-f8b5cc5cd-pst67   1/1     Running   0          11s   app=figlet-web,pod-template-hash=f8b5cc5cd
figlet-web-f8b5cc5cd-z7sd2   1/1     Running   0          11s   app=figlet-web,pod-template-hash=f8b5cc5cd
```

As you can see the deployment has injected a new label `pod-template-hash` and it is used to handle updates to the deployment.

## Updating the deployment

We've used the `anandology/figlet-web:green` image for our deployment. Let's change the image and see what happens.

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
        image: anandology/figlet-web:red
```

Notice that we have changed the image tag from `green` to `red`.

```
$ kubectl apply -f deployment.yaml
deployment.apps/figlet-web configured
```

Lets look at the pods and replica sets.

```
$ kubectl get rs
NAME                    DESIRED   CURRENT   READY   AGE
figlet-web-5756cff49c   2         2         2       15s
figlet-web-f8b5cc5cd    0         0         0       33s

$ kubectl get pods --show-labels
NAME                          READY   STATUS    RESTARTS   AGE   LABELS
figlet-web-5756cff49c-7gsml   1/1     Running   0          59s   app=figlet-web,pod-template-hash=5756cff49c
figlet-web-5756cff49c-rmb6k   1/1     Running   0          60s   app=figlet-web,pod-template-hash=5756cff49c
```

As you can see the deployment has created a new replicaset and changed the number of replicas of the old one to 0. It makes sures that the old replicaset is scaled down only after the new replicaset is ready. It allows us to rollback to the previous version quickly. All of this happens without any downtime.


## Task: create deployment for etherpad

Create a deployment for etherpad.

