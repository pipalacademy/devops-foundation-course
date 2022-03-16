# Diving Into Docker

Topics:

* Exposing ports
* Using volumes to persist data
* Using environment variables
* Inspecting containers
* Troubleshooting live containers

## Exposing Ports

* Run nginx container and expose the port to outside world

## Using Volumes

* Deploy nginx with a local directory as a volume
* Use golang container to run a go source file

## Using Environment Variables

* Hello world container with NAME as an environment variable
* Figlet with FIGLET_FONT as environment variable
* Cowsay with the COWFILE as environment variable
* Run postgres container with password as environment variable

## Inspecting containers

Learn about `docker inspect`

## Troubleshooting

Learn about `docker exec`.


## Tasks

### Task 1: figlet-web using docker

Dockerize [figlet-web][] and use that to setup <figlet-web.alpha.k8x.in>

[figlet-web]: https://github.com/anandology/figlet-web

### Task 2: Deploy graphviz-web and graphviz-api

Deploy [graphviz-web][] and [graphviz-api][] as two separate containers.
The frontend should be live at <http://graphviz.alpha.k8x.in/>.

Bonus points for https.

[graphviz-web]: https://github.com/pipalacademy/kubernetes-workshop/tree/master/graphviz-web
[graphviz-api]: https://github.com/pipalacademy/kubernetes-workshop/tree/master/graphviz-api