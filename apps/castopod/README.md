# KPS

## Install/Upgrade

To install or upgrade the mariadb charts, first edit the version number in `external-charts.txt` then run the following. You can review the changes with git diff or just go for it, in either case don't forget to git add/commit the changes.

```sh
# Pull charts
make externalCharts chart=mariadb

# Deploy
helmfile -f env/weeble/helmfile.yaml -l app=castopod apply --skip-deps
```

## Castopod Setup

Once deployed go to `https://castopod.tonygilkerson.us/cp-install` to create your Super Admin account.

```yaml
user: tgilkerson
email: tonygilkerson@yahoo.com
password: ****
```

Then you can go to `https://castopod.tonygilkerson.us/cp-admin`
