# CI/CD

CI/CD is setup for <https://gitlab.com/anandology/figlet-web>. See the `gitlab-ci.yml` file in that repo as an example and setup CI/CD for `graphviz-web`.

* Fork the <https://gitlab.com/anandology/graphviz-web> repo to your gitlab account
* Add a gitlab-ci.yml with three stages test, build and deploy with just echo statements
* Fix build and deploy stages, you may have to add docker/k8s secrets as varaibles in `settings > CI/CD`

---

## Install gitlab runner

Start runner using docker-compose.

```
$ cat docker-compose.yml
version: '3'

services:
  gitlab-runner:
    image: gitlab/gitlab-runner
    restart: always
    volumes:
      - ./config/:/etc/gitlab-runner/
      - /var/run/docker.sock:/var/run/docker.sock

$ docker-compose up -d
...
```

Register runner:

```
$ docker-compose exec gitlab-runner gitlab-runner register
...
```

You need to fix the config.

```
$ sudo nano config/config.toml
    ...
    disable_cache = false
    volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]
    shm_size = 0
```

Change the line `volumes = ...` to what is shown above.

And restart the runner.

```
$ docker-compose restart gitlab-runner
```

After this you need to add variables in `Settings > CI/CD > Variables`.

Add the following variables:

```
CI_REGISTRY_SERVER      registry.k8x.in
CI_REGISTRY_USER        k8x
CI_REGISTRY_PASSWORD    docker

CI_KUBECONFIG           ...
```

Run the following command to get the value for CI_KUBECONFIG:

```
$  cat ~/.kube/config | base64 -w 0; echo
...
```

Copy the output of the above command and set as value for `CI_KUBECONFIG`.

This would fix the `test` and `build` stages, but the `deploy` will still fail. That is because you don't have a deployment with name `figlet-web-dev` in your kubernetes namespace.

Fix that by doing the following:

* create a deployment `figlet-web-dev`
* create a service `figlet-web-dev`
* create an ingress controller figlet-web-dev exposing the service at <http://figlet-web-dev.alpha.k8x.in/>

After doing this, run the pipeline and that should succeed.

## Deployment

Create a secret storing the registry credentials.

```
$ kubectl create secret docker-registry regcred \
    --docker-server=registry.k8x.in \
    --docker-username=k8x \
    --docker-password=docker
...
```

Create a deployment.

```
$ cat deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: figlet-web-dev
  labels:
    app: figlet-web-dev
spec:
  replicas: 2
  selector:
    matchLabels:
      app: figlet-web-dev
  template:
    metadata:
      labels:
        app: figlet-web-dev
    spec:
      containers:
        - name: figlet-web
          image: registry.k8x.in/figlet-web:dev
          ports:
            - containerPort: 8080
          env:
            - name: FIGLET_FONT
              value: standard
      imagePullSecrets:
        - name: regcred

$ kubectl apply -f deployment.yaml
...
```