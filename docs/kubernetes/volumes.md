# Volumes

So far we've seen deploying stateless applications in kubernetes. Very often we need to manage state in real world applications. Volumes provide a way to persist data in kubernetes. Data that span restarts of the pods.

The way is done by creating PersistentVolumeClaim (pvc) objects, which would create persistent storage from the cloud.

Using volumes along with multiple replicas is a complicated affair. For now we'll limit to single replica.

## Jupyterlab

We've deployed jupyterlab in the previous lesson. What would happen to the created notebooks if you restart the pod? The notebooks will be lost because they are stored inside the container. You can see it yourself that by deleting the pod.

We need volumes to store data like this.

## Persistent Volume Claim

Volumes are created through PersistentVolumeClaim (pvc) objects.

Let's start with creating a pvc.

```
$ cat pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jupyterlab-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: do-block-storage

$ kubectl apply -f pvc.yaml
...
```

We can list the pvc objects to see the status.

```
$ kubectl  get pvc
NAME        STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS       AGE
jupyterlab-pvc   Pending                                      do-block-storage   4s
```

You can see that the status is pending. After a while, you'll see the status changed to `Bound`.

```
$ kubectl  get pvc
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       AGE
jupyterlab-pvc   Bound    pvc-75ec2f1f-cde5-4a74-baca-79eeae1483cb   1Gi        RWO            do-block-storage   40s
```

Let's update the `deployment.yaml` to use this volume.

```
$ cat deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jupyterlab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jupyterlab
  template:
    metadata:
      labels:
        app: jupyterlab
    spec:
      containers:
        - name: jupyterlab
          image: anandology/jupyterlab
          volumeMounts:
            - name: jupyterlab-notebooks
              mountPath: /notebooks
      volumes:
        - name: jupyterlab-notebooks
          persistentVolumeClaim:
            claimName: jupyterlab-pvc

$ kubectl apply -f deployment.yaml
deployment.apps/jupyterlab configured
```

Now the jupyterlab application is using the persistent volume for storing the file. Try adding a couple of files and delete the pod. You'll see the file continue to be present even deleting the pod.

## Exercise: Deploy postgres database server in kubernetes

Deploy postgres with a single replica in kubernetes. Use image `postgres`. You need to create only a deployment and a service and not an ingress controller because this is not an HTTP application.

We'll start with creating a deployment and service.

```
$ cat deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres
          env:
            - name: POSTGRES_USER
              value: test
            - name: POSTGRES_PASSWORD
              value: test123

$ cat service.yaml
apiVersion: v1
kind: Service
metadata:
    name: postgres
spec:
    type: NodePort
    selector:
        app: postgres
    ports:
    - protocol: TCP
      port: 5432
      targetPort: 5432
```

Let's apply them:

```
$ kubectl apply -f deployment.yaml -f service.yaml
deployment.apps/postgres configured
service/postgres configured
```

Let's look at the service.

```
$ kubectl  get svc postgres
NAME       TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
postgres   NodePort   10.245.148.224   <none>        5432:30335/TCP   7h40m

$ kubectl get nodes -o wide
NAME                   STATUS   ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP     OS-IMAGE                       KERNEL-VERSION         CONTAINER-RUNTIME
pool-y8imzr8sp-c3d2p   Ready    <none>   20m   v1.22.7   10.139.32.102   68.183.94.178   Debian GNU/Linux 10 (buster)   5.10.0-0.bpo.9-amd64   containerd://1.4.12
pool-y8imzr8sp-c3sm2   Ready    <none>   19h   v1.22.7   10.139.32.114   64.227.165.60   Debian GNU/Linux 10 (buster)   5.10.0-0.bpo.9-amd64   containerd://1.4.12
pool-y8imzr8sp-c3smp   Ready    <none>   19h   v1.22.7   10.139.32.113   64.227.165.38   Debian GNU/Linux 10 (buster)   5.10.0-0.bpo.9-amd64   containerd://1.4.12
```

We've created a service of type NodePort so that we can test it from our dev node. The port of the service is `30335`. The service will be accessible from any of the nodes. We'll use the IP address of the first node `68.183.94.178` to access the posgres server.

Please note that you may see a different port when you deploy your application.

Let's try to connect to the postgres server from the dev node. We've specified the user as `test` and password as `test123`.

Let's list all the databases.

```
$ psql -h 68.183.94.178 -p 30335 --user test -l
Password for user test:
                             List of databases
   Name    | Owner | Encoding |  Collate   |   Ctype    | Access privileges
-----------+-------+----------+------------+------------+-------------------
 postgres  | test  | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | test  | UTF8     | en_US.utf8 | en_US.utf8 | =c/test          +
           |       |          |            |            | test=CTc/test
 template1 | test  | UTF8     | en_US.utf8 | en_US.utf8 | =c/test          +
           |       |          |            |            | test=CTc/test
 test      | test  | UTF8     | en_US.utf8 | en_US.utf8 |
(4 rows)

```

And connect to the test databse.

```
$ psql -h 68.183.94.178 -p 30335 --user test test
Password for user test:
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 14.2 (Debian 14.2-1.pgdg110+1))
WARNING: psql major version 12, server major version 14.
         Some psql features might not work.
Type "help" for help.

test=# \d
Did not find any relations.

test=#
test=# create table person (id serial, name text, email text);
CREATE TABLE
test=#
test=# \d
             List of relations
 Schema |     Name      |   Type   | Owner
--------+---------------+----------+-------
 public | person        | table    | test
 public | person_id_seq | sequence | test
(2 rows)
```

We've created a new table `person`.

Try restarting the pod and you'll notice that the table is disappeared. That is because the database is stored inside the container and that gets deleted when the container dies.

We need to store the postgres data in an external volume to retain the data across restarts.

Let's create a PersistentVolumeClaim and attach it to the container.

```
$ cat pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: do-block-storage

$ kubectl apply -f pvc.yaml
persistentvolumeclaim/postgres-pvc configured
```

Now we need to change the deployment manifest to include the volume.

```
$ cat deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres
          env:
            - name: POSTGRES_USER
              value: test
            - name: POSTGRES_PASSWORD
              value: test123
          volumeMounts:
            - name: postgres-volume
              mountPath: /var/lib/postgresql/data
              subPath: pgdata
      volumes:
        - name: postgres-volume
          persistentVolumeClaim:
            claimName: postgres-pvc

$ kubectl apply -f deployment.yaml
deployment.apps/postgres configured
```

Now the application is deployed with a persistent volume and the data will live across the pod reboots.

## Exercise: Deploy klickr app in kubernetes

Git Repository:  <https://github.com/pipalacademy/klickr>

Docker image: `pipalacademy/klickr:22.03`

Environment variables:

* DATABASE_URL

The photos are stored at `/app/klickr/static/photos`.

You need to run the following services:

* klickr-db
* klickr-web

The DATABASE_URL will be of the format: `postgres://klickr:klickr@klicker-db/klickr`

You need to make a volume for the db and another for the photos.

Deploy the final app at `http://klickr.alpha.kube.k8x.in`.
