# Environment Variables

```
$ docker run --rm -it -e FOO=bar ubuntu /bin/bash
root@9a3f28828a52:/#
root@9a3f28828a52:/# echo $FOO
bar
root@9a3f28828a52:/# exit
```


Let's see if we can specify font of figlet using environment variables.

```
$ cat figlet.sh
#! /bin/bash

# use $FONT if defined, else use "standard"
FIGLET_FONT=${FONT:-standard}
figlet -f $FIGLET_FONT $*

$ chmod +x figlet.sh

$ cat Dockerfile
FROM ubuntu

RUN apt-get update
RUN apt-get install -y figlet

ADD figlet.sh /

ENTRYPOINT ["/figlet.sh"]
```

Let's build the image now.

```
$ docker build . -t figlet
...
Successfully tagged figlet
```

The docker image is built. Let's try running it.

```
$ docker run figlet docker
     _            _
  __| | ___   ___| | _____ _ __
 / _` |/ _ \ / __| |/ / _ \ '__|
| (_| | (_) | (__|   <  __/ |
 \__,_|\___/ \___|_|\_\___|_|

$ docker run -e FONT=slant figlet docker
       __           __
  ____/ /___  _____/ /_____  _____
 / __  / __ \/ ___/ //_/ _ \/ ___/
/ /_/ / /_/ / /__/ ,< /  __/ /
\__,_/\____/\___/_/|_|\___/_/

$ docker run -e FONT=lean figlet docker

         _/                      _/
    _/_/_/    _/_/      _/_/_/  _/  _/      _/_/    _/  _/_/
 _/    _/  _/    _/  _/        _/_/      _/_/_/_/  _/_/
_/    _/  _/    _/  _/        _/  _/    _/        _/
 _/_/_/    _/_/      _/_/_/  _/    _/    _/_/_/  _/

```

## Exercise: cowsay

Just like how figlet take a font argument, the cowsay command also take a cowfile as argument. Create a new version of the cowsay docker image to support environment variable COW.

You can use cowsay as follows to specify a different cow.

```
$ /usr/games/cowsay -f tux "docker is awesome"
 ___________________
< docker is awesome >
 -------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
```

You can try tux, dragon, elephant, gnu as cows. See `/usr/share/cowsay/cows` directory for all available options.

Once you add the support for environment variables, it should be possible to use it in the following ways:

```
$ docker run -e COW=tux cowsay docker is awesome
 ___________________
< docker is awesome >
 -------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
```
