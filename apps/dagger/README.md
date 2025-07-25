# Dagger

ref: [dagger docs](https://docs.dagger.io/ci/integrations/kubernetes/)

## Install/Upgrade

To install or upgrade...

```sh
# Deploy
helmfile -i -f env/zoo/helmfile.yaml.gotmpl -l app=dagger apply --skip-deps
```

## Connect to dagger engine in cluster from workstation

ref [custom-runner](https://docs.dagger.io/configuration/custom-runner)

You can point the dagger CLI to the engine running in the cluster like this

```sh
# export _EXPERIMENTAL_DAGGER_RUNNER_HOST="kube-pod://<podname>?context=<context>&namespace=<namespace>&container=<container>"
DAGGER_ENGINE_POD=$(kubectl get pods -l name=dagger-dagger-helm-engine -o custom-columns=":metadata.name"  --no-headers)
export _EXPERIMENTAL_DAGGER_RUNNER_HOST="kube-pod://${DAGGER_ENGINE_POD}?namespace=dagger&container=dagger-engine"

# verify
dagger query <<EOF
{
    container {
        from(address:"alpine") {
            withExec(args: ["uname", "-a"]) { stdout }
        }
    }
}
EOF

```