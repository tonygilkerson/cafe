# KPS

## Install/Upgrade

To install or upgrade the grafana and prometheus (aka KPS) charts, first edit the version number in `external-charts.txt` then run the following. You can review the changes with git diff or just go for it, in either case don't forget to git add/commit the changes.

```sh
# Pull charts
make externalCharts chart=kube-prometheus-stack

# Deploy
helmfile -f env/zoo/helmfile.yaml -l app=kps apply --skip-deps
```
