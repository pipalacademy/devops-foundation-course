# Docker Best Practices

## Pin version of docker images

For example, when building image for a python app:

```
FROM python:3.10
...
```

## Try to use alpine images whereever possible

## Use Multi-stage Build

Lets try 3 different Dockerfiles for the graphviz-web application.

Regular approach.

```
$ cat Dockerfile
FROM golang
WORKDIR /app
ADD . /app
RUN go build web.go
CMD ["/app/web"]

$ docker build . -t graphviz-web
...
$ docker images graphviz-web
REPOSITORY     TAG           IMAGE ID       CREATED         SIZE
graphviz-web   latest        3d41119392fc   23 hours ago    977MB
```

Using an alpine image.

```
$ cat Dockerfile.alpine
FROM golang:alpine
WORKDIR /app
ADD . /app
RUN go build web.go
CMD ["/app/web"]

$ docker build . -t graphviz-web:alpine -f Dockerfile.alpine
...
$ docker images graphviz-web
REPOSITORY     TAG           IMAGE ID       CREATED         SIZE
graphviz-web   alpine        f3dec315884d   9 minutes ago   342MB
graphviz-web   latest        3d41119392fc   23 hours ago    977MB
```

Let's try a multi-stage build now.

```
$ cat Dockerfile.multi-stage
FROM golang:alpine
WORKDIR /app
ADD . /app
RUN go build web.go

FROM alpine
WORKDIR /app
COPY --from=0 /app /app
CMD ["/app/web"]

$ docker build . -t graphviz-web:multi-stage -f Dockerfile.multi-stage
...
$ docker images graphviz-web
REPOSITORY     TAG           IMAGE ID       CREATED         SIZE
graphviz-web   multi-stage   8c37ac3ee317   4 minutes ago   11.9MB
graphviz-web   alpine        f3dec315884d   9 minutes ago   342MB
graphviz-web   latest        3d41119392fc   23 hours ago    977MB
```

## Leverage Docker Build Cache


