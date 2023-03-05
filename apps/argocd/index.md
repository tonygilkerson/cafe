# Argo CD

## Install

Here is the [official install](https://argo-cd.readthedocs.io/en/stable/getting_started/) docs

```sh
kubectl create namespace argocd

# Grap the argocd k8s manifests
# Edit the manifests as needed, ie add resource requests/limits
curl -o apps/argocd/k8s/manifests.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Apply
kubectl apply -n argocd -f apps/argocd/k8s
```

## Access UI

Look at secret in `argocd/argocd-initial-admin-secret`

```sh
kubectl -n argocd port-forward svc/argocd-server 8080:443
open http://localhost:8080
```
