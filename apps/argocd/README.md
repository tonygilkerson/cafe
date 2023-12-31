# Argo CD

## Install/Upgrade

Here is the [official install](https://argo-cd.readthedocs.io/en/stable/getting_started/) docs

To install or upgrade the Argo run the following. You can review the changes with git diff or just go for it, in either case don't forget to git add/commit the changes.

```sh
# Only first time install
kubectl create namespace argocd

# Grab the argocd k8s manifests
# Edit the manifests as needed, ie add resource requests/limits
make upgradeArgo

# Apply
kubectl apply -n argocd -f apps/argocd/k8s
```

## Access UI

Look at secret in `argocd/argocd-initial-admin-secret`

```sh
kubectl -n argocd port-forward svc/argocd-server 8080:443
open http://localhost:8080

# Or if DNS and Ingress are all setup
open https://argocd.tonygilkerson.us
```
