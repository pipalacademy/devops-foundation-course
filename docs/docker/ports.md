# Publishing Ports

Docker allows to publish a port in the container to the host.

```
$ docker run -p 8080:80 nginx
...
```

That would run nginx and publish the port 80 of the container to port 8080 of the host. After doing this, you'll be able to access it at http://alpha.k8x.in:8080/ (replace alpha with your hostname).

**Problem:** Nginx docker image serves the index.html file from `/usr/share/nginx/html`. Create a new docker image nginx-hello-docker that serves a page showing the following:

```
_   _      _ _         ____             _             _
| | | | ___| | | ___   |  _ \  ___   ___| | _____ _ __| |
| |_| |/ _ \ | |/ _ \  | | | |/ _ \ / __| |/ / _ \ '__| |
|  _  |  __/ | | (_) | | |_| | (_) | (__|   <  __/ |  |_|
|_| |_|\___|_|_|\___/  |____/ \___/ \___|_|\_\___|_|  (_)

```

Hint: You may have to write a `Dockerfile`.

## Exercise: Graphviz-web

Clone the git repository containing code samples.

```
$ git clone https://github.com/pipalacademy/kubernetes-workshop/
```

Task 1: Build an image for `graphviz-web` and run it as a container. The instructions are specified in the README.md file in graphviz-web directory.

At the end of this exercise, it should be possible to access it from your browser.

Task 2: Run `graphviz-api` as a contaner. The instructions are avalilable in README.md file in graphviz-api directory.

At the end of this exercise, you should be able to access the API using curl as shown in the README.

Task 3: Configure graphviz-web to talk to the graphviz-api instance. Instructions are again in the `README.md` of graphviz-web.

At the end of this exercise, clicking on "generate" should show the resulting image on the right.


Hints:

```
$ cd graphviz-web
$ docker run -it -p8080:8080 -v $PWD:/app golang
root@e1df1e009486:/go# cd /app/
root@e1df1e009486:/app# go build web.go
root@e1df1e009486:/app# ./web
2022/03/17 11:07:39 Starting the server...

$ cat Dockerfile
FROM golang
ADD . /app
WORKDIR /app
RUN go build web.go
CMD ["/app/web"]
```