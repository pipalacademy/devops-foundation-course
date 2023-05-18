# Metabase

[Metabase](https://metabase.com/) is an open-source analytics tool to make decisions from data. It allows creating charts and dashboards from data sitting in a database.

Let's try to run metabase in docker, docker-compose and kubernetes.

References:

* [Running Metabase on Docker - Metabase Documentation][1]

[1]: https://www.metabase.com/docs/latest/operations-guide/running-metabase-on-docker.html

## Overview

Metabase is an application written in Java and it stores the application data in a database. By default, it uses an in-process single-file database called H2. It is possible to use other databases like postgres or mysql for storing the application data, but we will stick to the simple H2 database for this exercises.

Metabase also need a database with the data to analyze. We need to create a database, load the data and configure metabase to use that. This database could be external database. For the purpose of this exercise we'll assume that the analytics database is already available.

## Docker

Let's start a docker container.

```
$ docker run -p 3000:3000 -e "JAVA_OPTS=-Xmx512m" metabase/metabase
...
```

You can access metabase at <http://alpha.k8x.in:3000/>.
