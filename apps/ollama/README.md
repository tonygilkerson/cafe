# Dagger

ref: [dagger docs](https://docs.dagger.io/ci/integrations/kubernetes/)

## Install/Upgrade

To install or upgrade...

```sh
# Deploy
helmfile -i -f env/zoo/helmfile.yaml.gotmpl -l app=ollama apply --skip-deps
```

## Pull Modles

Shell into the pod and run the following to pull a model.  See [supported modles](https://ollama.com/search?c=tools)

```sh
ollama pull qwen2.5-coder:7b
```
