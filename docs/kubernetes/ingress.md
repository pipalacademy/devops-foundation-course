# Ingress Controllers

Ingress Controller can be used to expose services in the cluster to outside world based on domain name.

An ingress controller is already setup in the cluster along with a load balancer. We can now create an ingress object specifying the service name and a hostname to expose it.

```
$ cat ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: figlet-web
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: figlet-web-alpha.kube.k8x.in
    http:
      paths:
      - backend:
          service:
            name: figlet-web
            port:
              number: 80
        path: /
        pathType: Prefix
```

I've setup the DNS `*.kube.k8x.in` to resolve to the IP address of the load balancer of the ingress controller.

Let's apply the ingress controller.

```
$ kubectl apply -f ingress.yaml
ingress.networking.k8s.io/figlet-web created

$ kubectl get ingress
NAME         CLASS    HOSTS                          ADDRESS   PORTS   AGE
figlet-web   <none>   figlet-web-alpha.kube.k8x.in             80      10s
```

The service will be accessible from <http://figlet-web-alpha.kube.k8x.in/>.

To avoid conflits with the subdomains, please suffix your subdomain with your namespace. Use `figlet-web-alpha`  or `figlet-web-beta` instead of just `figlet-web`.

## Exercise: Deploy etherpad

Deploy etherpad as ingress resource. It should be accessble from:

<http://etherpad-alpha.kube.k8x.in/>
