# Notebook

## Install/Upgrade

To install or upgrade the notebook chart run the following. You can review the changes with git diff or just go for it, in either case don't forget to git add/commit the changes.

```sh
# Pull charts
make getNotebook

# Deploy
helmfile -i -f env/weeble/helmfile.yaml -l app=notebook apply --skip-deps
```
