# Serial Gatway

## Install/Upgrade

To install or upgrade the serial-gateway chart run the following. You can review the changes with git diff or just go for it, in either case don't forget to git add/commit the changes.

```sh
# Pull charts
make getSerialGateway

# Deploy
helmfile -f env/weeble/helmfile.yaml -l app=serial-gateway apply --skip-deps
```
