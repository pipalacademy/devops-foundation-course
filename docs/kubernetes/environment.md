# Environment, ConfigMaps & Secrets

We can specify environment variables in the pod spec.

The `figlet-web` container supports specifying the figlet font as environment variable `FIGLET_FONT`.

Let's update the `figlet-web` deployment to change the figlet font to `lean`.

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
        env:
          - name: FIGLET_FONT
            value: lean

$ kubectl apply -f deployment.yaml
deployment.apps/figlet-web configured
```

Once we apply this file, we'll see the `lean` font at <http://figlet-web-alpha.kube.k8x.in/>.

Try changing the font to `block` or `dotmatrix` and see how it changes.

## ConfigMaps

Lot of times, it is tedius to keep all the configuration in the deployment files. An application could consist of multiple services and spreading the configuration across many deployment files is painful to manage. To address this, kubernetes provides a way to store configuration as an object in kubernetes and allows the deployment manifests to specify the environment values through ConfigMap.

Let's try to create a config map for figlet-web.

```
$ cat configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: figlet-web
data:
  figletFont: lean
```

We can apply this file to create the configmap object.

```
$ kubectl apply -f configmap.yaml
configmap/figlet-web created
```

We can list the existing config maps using:

```
$ kubectl get configmaps
NAME         DATA   AGE
figlet-web   1      41s
```

or describe one using:

```
$ kubectl get configmap figlet-web -o yaml
apiVersion: v1
data:
  figletFont: lean
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"figletFont":"lean"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"figlet-web","namespace":"alpha"}}
  creationTimestamp: "2022-03-22T03:41:10Z"
  name: figlet-web
  namespace: alpha
  resourceVersion: "318339"
  uid: f0364d4e-f6f4-44f4-96a6-944d18a787f0
```

We can now update the deployment manifest and apply to use the value from the configmap.

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
        env:
          - name: FIGLET_FONT
            valueFrom:
              configMapKeyRef:
                name: figlet-web
                key: figletFont

$ kubectl apply -f deployment.yaml
deployment.apps/figlet-web configured
```

## Exercise: Deploy jupyterlab and set password using configmap / secret

Use image `anandology/jupyterlab` to deploy jupyterlab instance in the kubernetes cluster.

See <https://github.com/anandology/jupyterlab-docker> for instructions.

Task 1: Create deployment, service and ingress to make it available at <http://jupyterlab-alpha.kube.k8x.in/>

Task 2: Change the password to `docker` by setting the JUPYTERLAB_TOKEN in the environment.

Task 3: Use a config mapt to store the jupyterlab password and reference the configmap in the deplopyment manifest
