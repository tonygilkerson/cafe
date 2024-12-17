# Gitlab

## Install/Upgrade

To install or upgrade...

```sh
# Deploy
helmfile -i -f env/zoo/helmfile.yaml -l app=gitlab apply --skip-deps
```
