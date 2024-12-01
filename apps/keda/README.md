# Serial Gatway

## Install/Upgrade

To install or upgrade the serial-gateway chart run the following. You can review the changes with git diff or just go for it, in either case don't forget to git add/commit the changes.

```sh
# Pull charts
make externalCharts chart=keda

# Deploy
helmfile -i -f env/zoo/helmfile.yaml -l app=keda apply --skip-deps
```
