# Argo CD

## Make Helm Chart

Turn the [official install](https://argo-cd.readthedocs.io/en/stable/getting_started/) into a chart

```sh
curl -o apps/argocd/charts/argocd/templates/install.yaml  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Access UI

Look at secret in `argocd/argocd-initial-admin-secret`

```sh
kubectl -n argocd port-forward svc/argocd-server 8080:443
open http://localhost:8080
```