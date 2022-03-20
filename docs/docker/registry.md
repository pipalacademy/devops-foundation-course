# Working with Docker Registry

```
$ docker login registry.k8x.in
Username: k8x
Password:
```

After you login, run a container using image from that registry.

```
$ docker run registry.k8x.in/figlet
Unable to find image 'registry.k8x.in/figlet:latest' locally
latest: Pulling from figlet
7c3b88808835: Pull complete
be9adab82d8b: Pull complete
e7ba00a46e51: Pull complete
Digest: sha256:bc65252824dd9d81782068dcc9d24c83ac8e200c3654fff6f6dd252e62788209
Status: Downloaded newer image for registry.k8x.in/figlet:latest
 _          _ _             _            _
| |__   ___| | | ___     __| | ___   ___| | _____ _ __
| '_ \ / _ \ | |/ _ \   / _` |/ _ \ / __| |/ / _ \ '__|
| | | |  __/ | | (_) | | (_| | (_) | (__|   <  __/ |
|_| |_|\___|_|_|\___/   \__,_|\___/ \___|_|\_\___|_|
```

## Pushing images

Let's push a new image to the regitry.

Assuming you already have a docker image with name `figsay`, follow the following instructions.

```
$ docker tag figsay registry.k8x.in/figsay-alpha
$ docker push registry.k8x.in/figsay-alpha
```

I've used my hostname as suffix for the image name so that everyone in the class can also push their images.

Once the image is pushed to the registry, it can accessble from any machine.

```
$ docker run registry.k8x.in/figsay-alpha
Unable to find image 'registry.k8x.in/figsay-alpha:latest' locally
latest: Pulling from figsay-alpha
...
 _________________________________________________________
/  _          _ _             _            _              \
| | |__   ___| | | ___     __| | ___   ___| | _____ _ __  |
| | '_ \ / _ \ | |/ _ \   / _` |/ _ \ / __| |/ / _ \ '__| |
| | | | |  __/ | | (_) | | (_| | (_) | (__|   <  __/ |    |
| |_| |_|\___|_|_|\___/   \__,_|\___/ \___|_|\_\___|_|    |
\                                                         /
 ---------------------------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```