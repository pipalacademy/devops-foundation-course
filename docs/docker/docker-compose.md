# Running Multi-container Applications

!!! quote

    “Alone we can do so little; together we can do so much.”

    – Helen Keller

Introduction to running multi-container applications with docker-compose.

# Graphviz

Let's run graphviz-web and graphviz-api using docker-compose.

```
$ cat docker-compose.yml
version: "3"
services:
    web:
        image: graphviz-web
        ports:
          - 8080:8080
        environment:
          GRAPHVIZ_API_ENDPOINT: "http://alpha.k8x.in:8008/dot"
    api:
        image: graphviz-api
        ports:
          - 8008:8000

$ docker-compose up
...
```

The `docker-compose up` will start both the containers with everything setup.

You should be able to visit `http://alpha.k8x.in:8080/` to visit the graphviz-web.

## Tasks

### Setup bookmarks service - links.alpha.k8x.in

Setup [Shaarli][], an opensource bookmarking service using docker-compose at https://links.alpha.k8x.in/.

[Shaarli]: https://shaarli.readthedocs.io/en/master/

### Setup Klickr

Start klickr app on your node.

<https://github.com/pipalacademy/klickr>

### Deploy Etherpad on your instance

See <https://etherpad.org> for details.

Your goal is to setup <http://pad.alpha.k8x.in/>. You may have to use docker-compose to set this up.

You can look at a sample etherpad instance at:
<https://pad.libreops.cc/>

Make sure that your application persists the data. If the docker is restarted, the application data should not be lost.

Etherpad support multiple database engines. Use the simplest one `sqlite` and mount a file from host to use the database file.

When you are configuring nginx, you will have to configure it to handle websockets. Please refer to the nginx documentaion for details.
<https://nginx.org/en/docs/http/websocket.html>