# The Cafe

Deployment scripts for The Cafe

## Kubectl

To run from my Mac

```sh
export KUBECONFIG=~/.kube/config-files/weeble.yaml 
kubectl cluster-info
```

## MicroK8s

```bash
microk8s enable ingress dns cert-manager hostpath-storage
```

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

## kps

Need to label namespaces that you want to monitor

```sh
kubectl label ns kps tonygilkerson.us/alerting=enabled
```

## Access UI

Look at secret in `argocd/argocd-initial-admin-secret`

```sh
kubectl -n argocd port-forward svc/argocd-server 8080:443
open http://localhost:8080
```

## Github Actions Setup

* Create a [token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with **repo** and **write:packages** scopes.
* Once the token is created, copy it and navigate to your repository [Settings > Secrets](https://github.com/tonygilkerson/cafe/settings/secrets/actions/)
* Create a secret called `AEG_REGISTRY_TOKEN` and insert the token as the value. Then it can be referenced like this `${{ secrets.GITHUB_REGISTRY_TOKEN }}` in the CI pipeline.

>Expiration: This token expires on Wed, May 10 2023. To set a new expiration date, you must [regenerate the token](https://github.com/settings/tokens/1096032899)

## Workflow permissions

Go to [Actions->General->Workflow permissions](https://github.com/tonygilkerson/serial-gateway/settings/actions)

* Select `Read and write permissions`
* Check `Allow Github Actions to create and approve pull requests`

## Cert-Manager Fix

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

I added this to `/etc/hosts` on the cluster node but not sure if that is needed now

```sh
10.0.0.100  tonygilkerson.us
```

Also next time try this instead:

Edit coredns configmap so we point to the resolv.conf file

```sh
microk8s kubectl edit cm coredns -n kube-system
```

Set the forward section to:

```text
forward . /etc/resolv.conf 8.8.8.8  8.8.4.4
```

## Initial Server Setup

Starting with a clean install of Ubuntu

```sh
# Firewall
sudo ufw status
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 16443 # k8s api
sudo ufw enable

# SSH
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install openssh-server

sudo systemctl start ssh
sudo systemctl stop ssh
sudo systemctl restart ssh

sudo systemctl status ssh

# Containers
sudo apt install podman-docker

# git
sudo apt install git
git config --global user.name "Tony Gilkerson"
git config --global user.email "tonygilkerson@yahoo.com"

# microk8s
sudo snap install microk8s --classic --channel=latest/stable
```

On my workstation add the following:

```sh
# ~/.ssh/config
# 10.0.0.25 is the wan address of the dd-wrt router, it will port forward 22
# My IOT cluster
Host weeble
  ForwardAgent yes
  Hostname 10.0.0.25
  User tgilkerson
```

## Dev Tools

```sh
sudo apt-get install curl

cd ~/github
git clone git@github.com:tonygilkerson/dotfiles.git
./dev-tools/dev_tools_install.sh
```
