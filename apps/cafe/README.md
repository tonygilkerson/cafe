# Cafe

## Install/Upgrade

To install or upgrade the cafe app, first edit the manifests here `apps/cafe/charts/cafe/template` then run the following.

```sh
# Deploy
helmfile -i -f env/zoo/helmfile.yaml.gotmpl -l app=cafe apply --skip-deps
```
