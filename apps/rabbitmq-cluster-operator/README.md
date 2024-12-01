# rabbitmq-cluster-operator

## Install/Upgrade

To install or upgrade the mariadb charts, first edit the version number in `external-charts.txt` then run the following. You can review the changes with git diff or just go for it, in either case don't forget to git add/commit the changes.

```sh
# Pull charts
make externalCharts chart=rabbitmq-cluster-operator

# Deploy
helmfile -f env/zoo/helmfile.yaml -l app=rabbitmq-cluster-operator apply --skip-deps
```
