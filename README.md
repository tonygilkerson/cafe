# The Cafe

Setup for the Cafe

Github Page: [https://tonygilkerson.github.io/cafe/](https://tonygilkerson.github.io/cafe/)

## Day 2

```sh
ssh -D 9995 zoo

# in a new terminal
k config set-context zoo
```

## Day 1 - Initial Server Setup

Starting with a clean install of Ubuntu

```sh
# get current
sudo apt update
sudo app upgrade

# SSH
sudo apt install openssh-server

sudo systemctl start ssh
sudo systemctl stop ssh
sudo systemctl restart ssh

sudo systemctl status ssh
```

## Static IP

In the router I should have DHCP starting at 100 or something like that so I can set a static IP address with no conflicts. Use the use to configure the following:

* IP: 192.168.50.10
* mask: 255.255.255.0
* gateway: 192.168.50.1
* dns: 8.8.8.8,8.8.4.4

> Note - At this point you can `ssh zoo` from your laptop to finish the setup

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
sudo ufw allow 30080 # k8s node ports
sudo ufw allow 30443 # k8s node ports
sudo ufw enable


sudo apt install iotop

# clamav ref: https://www.inmotionhosting.com/support/security/install-clamav-on-ubuntu/
sudo apt install clamav clamav-daemon -y

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
K8SVERSION=1.31
sudo snap refresh microk8s --channel=$K8SVERSION/stable
microk8s stop
microk8s start
```

## Dev Tools

```sh
sudo apt install curl

mkdir -p ~/github/tonygilkerson
cd ~/github/tonygilkerson
git clone git@github.com:tonygilkerson/dotfiles.git
cd dotfiles
./dev-tools/dev_tools_install.sh
```

## MicroK8s

```bash
# If microk8s is already installed and you want to start over run reset
sudo microk8s reset --destroy-storage

mkdir ~/.kube
sudo microk8s enable dns hostpath-storage metrics-server
sudo microk8s config > ~/.kube/config
```

```sh
mkdocs serve
```

Github pages will auto deploy to [https://tonygilkerson.github.io/cafe/](https://tonygilkerson.github.io/cafe/)

## Cert Manager

Install CRDs to break chicken and egg. See [cert-manager doc](https://cert-manager.io/docs/installation/helm/)

```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.3/cert-manager.crds.yaml
```

## kps

Need to label namespaces that you want to monitor

## CRDs

```sh
# Apply CRDs first to avoid chicken/egg
kubectl apply -f external-charts/kube-prometheus-stack/charts/crds/crds --server-side

# install cafe first to create namespaces
# use sync the first time
helmfile -i -f env/zoo/helmfile.yaml -l app=cafe sync --skip-deps
```

## GatewayAPI

```sh
# Install CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

# Apply service mesh
helmfile -i -f env/zoo/helmfile.yaml -l app=service-mesh apply --skip-deps

# After you create a Gateway resource you will need to patch the nodeports for the port-forwarding to work
kubectl -n istio-system patch svc cafe-gateway-istio --type merge -p='{"spec":{"ports":[{"name":"http","nodePort":30080,"port":80,"protocol":"TCP","targetPort":80},{"name":"https","nodePort":30443,"port":443,"protocol":"TCP","targetPort":443}]}}'

# Allow access to cafe-gateway
# DEVTODO - I should add this to the namespace chart
# DEVTODO - create one gatway will allow all namespaces or put the gateways in the app namespaces
# kubectl label ns istio-system cafe-gateway=enabled
```

## Httpbin

Deploy httpbin and use it to verify the Service Mesh

```sh
helmfile -i -f env/zoo/helmfile.yaml -l app=httpbin apply --skip-deps
```

## Slack

Create slack url secret

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

## Docs Dev

On your Mac workstation
One-time setup

```sh
python3 -m venv .venv
source .venv/bin/activate
pip3 install --upgrade pip
pip3 install mkdocs-material
pip3 install mkdocs-mermaid2-plugin
# pip3 install mkdocs-simple-plugin
# pip3 install mkdocs-alabaster
```

Develop

```sh
make docdev
open http://127.0.0.1:8000/
```

Publish

```sh
make docpub
open https://tonygilkerson.github.io/cafe/
```



---







## Old Archive Stuff

This no longer applies but might be useful as a reference. If you have not used this in a while then you can delete this section 2023-Mar

### Cert-Manager Fix

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

Edit coredns configmap so we point to the resolv.conf file

```sh
microk8s kubectl edit cm coredns -n kube-system
```

Set the forward section to:

```text
forward . /etc/resolv.conf 8.8.8.8  8.8.4.4
```
