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

Create a token with **repo** and **write:packages** scopes. Once the token is created, copy it and navigate to your repository `Settings > Secrets`. Create a secret called `AEG_REGISTRY_TOKEN` and insert the token as the value. Then it can be referenced like this `${{ secrets.GITHUB_REGISTRY_TOKEN }}` in the CI pipeline.

## Install Ingress Controller

```bash
microk8s enable ingress
```
