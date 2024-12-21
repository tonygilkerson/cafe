# home-assistant

## Install/Upgrade

```sh
# Deploy
helmfile -i -f env/zoo/helmfile.yaml -l app=home-assistant apply --skip-deps
```

## Config

```sh
/config# cat configuration.yaml
#
# my config
#

# Loads default set of integrations. Do not remove.
default_config:

# Load frontend themes from the themes folder
frontend:
  themes: !include_dir_merge_named themes

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml

http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 10.1.7.63 # the cafe-gateway-istio pod's ip

```