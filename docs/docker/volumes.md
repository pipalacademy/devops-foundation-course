# Volumes

Let's try running nginx with volumes.

```
$ echo "Hello docker" > index.html

$ docker run -v $PWD:/usr/share/nginx/html -p8090:80 nginx
...
```

You can acess nginx from <http://alpha.k8x.in:8090/>.

