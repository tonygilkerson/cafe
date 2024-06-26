# The Cafe

Setup for the Cafe

Githup Page: [https://tonygilkerson.github.io/cafe/](https://tonygilkerson.github.io/cafe/)

## Initial Server Setup

Starting with a clean install of Ubuntu

```sh
# Look at current setting
$ sudo systemctl get-default
graphical.target

# Set to text mode
# You will still be able to use X by typing startx after you logged in.
sudo systemctl enable multi-user.target --force
sudo systemctl set-default multi-user.target

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
sudo apt-get install iotop

# clamav ref: https://www.inmotionhosting.com/support/security/install-clamav-on-ubuntu/
sudo apt-get install clamav clamav-daemon -y

# Common clamav commands

# Scan all files, starting from the current directory:
clamscan -r /

# Scan files but only show infected files:
clamscan -r -i /path-to-folder

# Scan files but don’t show OK files:
clamscan -r -o /path-to-folder

# Scan files and send results of infected files to a results file:
clamscan -r /path-to-folder | grep FOUND >> /path-folder/file.txt

# Scan files and move infected files to a different directory:
clamscan -r --move=/path-to-folder /path-to-quarantine-folder

# Manually update the ClamAV signature database:
sudo systemctl stop clamav-freshclam
sudo freshclam
sudo systemctl start clamav-freshclam

# After executing the command the screen will turn off automatically every minute (if idle). 
setterm --blank 1

# Containers
sudo apt install podman-docker

# git
sudo apt install git
git config --global user.name "Tony Gilkerson"
git config --global user.email "tonygilkerson@yahoo.com"

# microk8s
sudo snap install microk8s --classic --channel=latest/stable

# microk8s upgrade
K8SVERSION=1.29
sudo snap refresh microk8s --channel=$K8SVERSION/stable
microk8s stop
microk8s start
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

## MicroK8s

```bash
# If microk8s is already installed an you want to start over run reset
microk8s reset --destroy-storage

microk8s enable dns cert-manager hostpath-storage metrics-server
microk8s config > ~/.kube/config
```

## Cert Manager

Install CRDs to break chicken and egg. See [cert-manager doc](https://cert-manager.io/docs/installation/helm/)

```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.5/cert-manager.crds.yaml
```

## Docs Dev

Install themes

```sh
sudo apt-get install python3-pip
sudo apt-get install mkdocs

pip3 install mkdocs-material
pip3 install mkdocs-mermaid2-plugin
pip3 install mkdocs-simple-plugin
pip3 install mkdocs-alabaster
```

Edit markdown files and test with

```sh
mkdocs serve
```

Github pages will auto deploy to [https://tonygilkerson.github.io/cafe/](https://tonygilkerson.github.io/cafe/)

## kps

Need to label namespaces that you want to monitor

```sh
# Deploy the visibility stack
# Use "sync" the first time to avoid "no CRD" error
helmfile -i -f env/weeble/helmfile.yaml sync
```

Create slack url secret:

```sh
SLACK_WEBHOOK_URL="REPLACE-ME"
kubectl -n cafe create secret generic slack-webhook-url-mbx-door --from-literal=url=$SLACK_WEBHOOK_URL

SLACK_WEBHOOK_URL="REPLACE-ME"
kubectl -n cafe create secret generic slack-webhook-url-mbx-cars --from-literal=url=$SLACK_WEBHOOK_URL
```

## Github Actions Setup

* Create a [token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with **repo** and **write:packages** scopes.
* Once the token is created, copy it and navigate to your repository [Settings > Secrets](https://github.com/tonygilkerson/cafe/settings/secrets/actions/)
* Create a secret called `AEG_REGISTRY_TOKEN` and insert the token as the value. Then it can be referenced like this `${{ secrets.GITHUB_REGISTRY_TOKEN }}` in the CI pipeline.

>Expiration: This token expires on Wed, May 10 2023. To set a new expiration date, you must [regenerate the token](https://github.com/settings/tokens/1096032899)

## Github Workflow permissions

Go to [Actions->General->Workflow permissions](https://github.com/tonygilkerson/serial-gateway/settings/actions)

* Select `Read and write permissions`
* Check `Allow Github Actions to create and approve pull requests`

## Github Auth

Reference: [this](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

```sh
ssh-keygen -t ed25519 -C "tonygilkerson@yahoo.com"
# You will need to save your public key in Github
Your public key has been saved in /home/tgilkerson/.ssh/id_ed25519.pub
```

Go to your [Github Keys](https://github.com/settings/keys) and add the above as **tgilkerson on weeble**

## GatewayAPI

```sh
# Install CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# After you create a Gateway resource you will need to patch the nodeports for the port-forwarding to work
kubectl -n istio-system patch svc cafe-gateway-istio --type merge -p='{"spec":{"ports":[{"name":"http","nodePort":30080,"port":80,"protocol":"TCP","targetPort":80},{"name":"https","nodePort":30443,"port":443,"protocol":"TCP","targetPort":443}]}}'

# Allow access to cafe-gateway
# DEVTODO - I should add this to the namespace chart
kubectl label ns istio-system cafe-gateway=enabled
```

---

## Old Archive Stuff

This no longer applies but might be useful as a reference. If you have not used this in a while then you can delete this section 2023-Mar

### Cert-Manager Fix

**cert-manager** needs patched to fix this error

>"error"="failed to perform self check GET request ...

Add DNS entries in the cert-manager deployment at `spec.template.spec.dnsConfig`

```yaml
# DEVTODO - dont install cert-manager as a addon, instead vendor the cart and make this change to the chart

dnsConfig:
  nameservers:
    - 1.1.1.1
    - 8.8.8.8
dnsPolicy: None
```

Edit coredns configmap so we point to the resolv.conf file

```sh
microk8s kubectl edit cm coredns -n kube-system
```

Set the forward section to:

```text
forward . /etc/resolv.conf 8.8.8.8  8.8.4.4
```
