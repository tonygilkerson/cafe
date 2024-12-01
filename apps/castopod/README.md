# KPS

## Install/Upgrade

To install or upgrade the mariadb charts, first edit the version number in `external-charts.txt` then run the following. You can review the changes with git diff or just go for it, in either case don't forget to git add/commit the changes.

```sh
# Pull charts
make externalCharts chart=mariadb

# Deploy
helmfile -f env/zoo/helmfile.yaml -l app=castopod sync --skip-deps
```

## Castopod Setup

Once deployed go to `https://castopod.tonygilkerson.us/cp-install` to create your Super Admin account.

```yaml
user: tgilkerson
email: tonygilkerson@yahoo.com
password: ****
```

Then you can go to `https://castopod.tonygilkerson.us/cp-admin`

## Storage

The two PVC created by this app are used for storing the castopod media and db stuff.  If you want to delete then reinstall and still retain the data then you will need to edit the PVs and set the reclaim policy to `Retain`

```sh
kubectl patch pv <your-pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

## MP3

```sh
ffmpeg -i somefile.mp3 -f segment -segment_time 3 -c copy out%03d.mp3
```

Where `-segment_time` is the amount of time you want per each file (in seconds).
