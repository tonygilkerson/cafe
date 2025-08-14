# Gitlab Runner

## Install/Upgrade

To install or upgrade...

```sh
# Deploy
helmfile -i -f env/zoo/helmfile.yaml.gotmpl -l app=gitlab-runner apply --skip-deps
```

## Update Helm Chart

To look for new chart versions

```sh
helm repo update
helm search repo gitlab-runner/gitlab-runner --versions

# edit external-charts.txt
make externalCharts chart=gitlab-runner

# see install/upgrade above
```


## New Runner

ref: [new creation workflow](https://docs.gitlab.com/ee/ci/runners/new_creation_workflow.html#creating-runners-programmatically)

```sh
# create a new runner in the UI and copy the "The runner authentication token"
token=REDACTED

kubectl apply -f -<<EOF
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-runner
  namespace: gitlab-runner
type: Opaque
stringData:
  runner-registration-token: ""
  runner-token: "$token"
EOF
```
