# The Cafe

Deployment scripts for The Cafe

## Docs Dev

Install themes

```sh
pip3 install mkdocs-material
pip3 install mkdocs-mermaid2-plugin
pip3 install mkdocs-simple-plugin
pip3 install mkdocs-alabaster
```

Edit markdown files and test with

```sh
mkdocs serve
```

## Github Actions Setup

* Create a [token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with **repo** and **write:packages** scopes. 
* Once the token is created, copy it and navigate to your repository [Settings > Secrets](https://github.com/tonygilkerson/cafe/settings/secrets/actions/)
* Create a secret called `AEG_REGISTRY_TOKEN` and insert the token as the value. Then it can be referenced like this `${{ secrets.GITHUB_REGISTRY_TOKEN }}` in the CI pipeline.


>Expiration: This token expires on Wed, May 10 2023. To set a new expiration date, you must [regenerate the token](https://github.com/settings/tokens/1096032899)

## Install Ingress Controller

```bash
microk8s enable ingress dns cert-manager
```

**cert-manager** needs patched to fix this error

>"error"="failed to perform self check GET request ...


Add DNS entries in the cert-manager deployment at `spec.template.spec.dnsConfig`

```yaml
dnsConfig:
  nameservers:
    - 1.1.1.1
    - 8.8.8.8
dnsPolicy: None
```
