# Pods

Pods are the smallest deployable units of computing in Kubernetes.

A pod is one or more related containters, shared storage and networking. For this lesson, we are only going to look at pods with just single container.

## Listing pods

We are list all the available pods using the following command:

```
$ kubectl get pods
No resources found in alpha namespace.
```

The respose is empty as we are not running any pods yet.

## Creating a pod

We can create a pod in the kubernetes cluster by specifying it an YAML file and applying the file.

```
$ cat pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: figlet-web
spec:
  containers:
    - name: figlet-web
      image: anandology/figlet-web
      ports:
        - containerPort: 8080
```

Let's try to understand what each of these fields mean:

* apiVersion -- the version of the kubernetes API used to create this object
* metadata -- metadata about the object. For a pod, we need to include the `name` field
* spec -- the specification of the object. For a pod, this includes the container details.

The image for the `figlet-web` is avaiale as `anandology/figlet-web` in the docker hub.

The field `containerPort` specifies the port on which the app in the container is listening at. Please note that this field only informational - it is meant for communicating what ports the container is using to ther developers, and kubernetes doesn't use this at all.

Let's tell kubernetes to create this pod by apply the yaml file.

```
$ kubectl apply -f pod.yaml
pod/figlet-web created
```

That would tell the API server to create a new pod with the details mentioned in the YAML file.

If you immediately list the pods, you'll see a new pod with status `ContainerCreating`.

```
$ kubectl get pods
NAME                           READY   STATUS             RESTARTS    AGE
figlet-web                     0/1     ContainerCreating   0          3s
```

With in a couple of seconds, the status will change to `Running`.

```
$ kubectl get pods
NAME                           READY   STATUS             RESTARTS    AGE
figlet-web                     1/1     Running            0           13s
```

If you want to see which node the pod is running, pass `-o wide` option to `kubectl`.

```
$ kubectl  get pods -o wide
NAME         READY   STATUS    RESTARTS   AGE    IP             NODE                 NOMINATED NODE   READINESS GATES
figlet-web   1/1     Running   0          4m7s   10.244.1.140   k8s-workshop-c3gvg   <none>           <none>
```

To make this happen, the following things are done behind the scenes.

* The kubectl command sent the pod info to the API server
* The api-server created a new pod object
* kube-scheduler see an unschdeuled pod and assignes it to a node
* the kubelet on that node see that a pod is allocated to that node but no containers are running and starts creating the containers of that pod

## Details of a pod

We can use `kubectl describe pod` to get more details about the pod.

```
$ kubectl describe pod figlet-web
Name:         figlet-web
...
Node:         k8s-workshop-c3gvg/10.139.32.104
Start Time:   Sun, 20 Mar 2022 19:58:15 +0000
...
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  5s    default-scheduler  Successfully assigned alpha/figlet-web to k8s-workshop-c3gvg
  Normal  Pulling    4s    kubelet            Pulling image "anandology/figlet-web"
  Normal  Pulled     2s    kubelet            Successfully pulled image "anandology/figlet-web" in 2.053733993s
  Normal  Created    2s    kubelet            Created container figlet-web
  Normal  Started    1s    kubelet            Started container figlet-web
```

It shows a lot of information about the pod. One of the intersting things that you may want to check when troubleshooting is the events section. It shows all the events that affected this pod.

## Accessing the pod

We can temporarily access the port of the container running the pod by using port-forward.

```
$ kubectl port-forward figlet-web-5c857bf5c6-7rbcm --address 0.0.0.0 9090:8080
Forwarding from 0.0.0.0:9090 -> 8080
```

That would forward the port 8080 of the pod to port 9090 on the node where this command is run.
You can visit http://alpha.k8x.in:9090/ to access the app.

## Troubleshooting a pod

Just like we were able to get a shell into a container using `docker exec`, we could get a shell into a container running in kubernetes using `kubectl exec`.

```
$ kubectl exec figlet-web -- bash
root@figlet-web:/app#
```

We can inspect the container. For example, we could look at the processes running in the container.

```
root@figlet-web:/app# ps -A
    PID TTY          TIME CMD
      1 ?        00:00:00 gunicorn
      7 ?        00:00:00 gunicorn
     39 pts/0    00:00:00 bash
     54 pts/0    00:00:00 ps
```

We could even make changes to the files to trobleshoot an issue, even though the editor like nano or vi will not be available in the container. Let's try to edit the style to change the text color fron green to red.

```
root@figlet-web:/app# sed -i 's/green/red/' static/style.css
```

The `sed` command replaced all the occurances of `green` with `red` in the file `staic/style.css`. Now visit `http://alpha.k8x.in:9090/` and reload your browser. You'll see the text in red color!

## Deleting a pod

You can delete a pod using `kubectl delete`.

```
$ kubectl delete pod figlet-web
pod "figlet-web" deleted
```

## Discussion

Pod is an abstraction that manages one or more related containers. The pod takes care of starting the containers and restarting on failures etc.  You can try killing the main process in the container and see the pod restarts the container.

```
$ kubectl exec figlet-web -- bash
root@figlet-web:/app# kill 1
root@figlet-web:/app# command terminated with exit code 137
```

The `kill` command killed the main process (pid 1) and that caused the container to quit.

If you look at the `kubectl get pods`, you'll notice that the number of restarts is now 1 for this pod.

```
$ kubectl get pods
NAME         READY   STATUS    RESTARTS      AGE
figlet-web   1/1     Running   1 (85s ago)   4m42s
```

While it is possible to create individual pods as shown in this lesson, it is not very common to create individual pods by hand. The standard practice is to create a deployment, specifying the number of pods to create and a template for the pods. We'll learn about deployments in the next lesson.

Also, port-forward is only a temporary measure used to troubleshoot and never used in production. That is achived using service and ingress objects. We'll learn about them in the upcoming lessons.

## Exercise: Deploy etherpad

Deploy [etherpad][] as a pod in kubernetes and forward the port to make it accessible on your node.

[etherpad]: https://etherpad.org/

Instructions for using etherpad on docker are available at:
<https://github.com/ether/etherpad-lite/blob/develop/doc/docker.md>

Please node that the port on which etherpad docker container runs is `9001`.
