# The Cafe

Setup for the Cafe

Github Page: [https://tonygilkerson.github.io/cafe/](https://tonygilkerson.github.io/cafe/)

## Workstation Setup for signing commits

```sh
# Create a SSH key to use for signing
ssh-keygen -t ed25519 -C "tonygilkerson@yahoo.com" -f ~/.ssh/id_ed25519_sign

git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519_sign.pub
git config --global commit.gpgsign true

echo "git $(cat ~/.ssh/id_ed25519_sign.pub)" > ~/.ssh/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
chmod 644 ~/.ssh/allowed_signers

# make sure key is listed
ssh-add -l
# If your key is not listed, add it:
ssh-add ~/.ssh/id_ed25519_sign


# add a change thin
git commit -sm "sign commit"

# verify
git log --show-signature -1 

# Should look like this
$ cat .gitconfig
[user]
	name = Tony Gilkerson
	email = tonygilkerson@yahoo.com
	signingkey = /Users/tonygilkerson/.ssh/id_ed25519.pub
[pull]
	rebase = false
[gpg]
	format = ssh
[commit]
	gpgsign = true
[gpg "ssh"]
	allowedSignersFile = /Users/tonygilkerson/.ssh/allowed_signers
```

This did not work to undo

```sh
git config --global --unset commit.gpgsign
git config --global --unset user.signingkey
git config --global --unset user.gpg.ssh.allowedSignersFile
```


## Initial Server Setup

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
sudo ufw allow nfs
sudo ufw allow from 192.168.50.11 to any port nfs # Allow gitlab
sudo ufw allow from 192.168.50.12 to any port nfs # Allow home assistant
sudo ufw allow 16443 # k8s api
sudo ufw allow 30080 # k8s node ports for Istio
sudo ufw allow 30443 # k8s node ports for Istio
sudo ufw allow 31080 # k8s node ports for gitlab
sudo ufw allow 31443 # k8s node ports for gitlab
sudo ufw enable

sudo apt install apache2-utils
sudo apt install gnome-tweak-tool
sudo apt install iotop
sudo apt install nmap
sudo apt install xq

# After executing the command the screen will turn off automatically every minute (if idle). 
setterm --blank 1


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

# Containers
sudo apt install podman-docker

# git
sudo apt install git
git config --global user.name "Tony Gilkerson"
git config --global user.email "tonygilkerson@yahoo.com"

# microk8s
sudo snap install microk8s --classic --channel=latest/stable

# microk8s upgrade
# see: https://microk8s.io/docs/upgrading

# K8SVERSION=1.31
K8SVERSION=1.32 # installed on 1/25/2025
sudo snap refresh microk8s --channel=$K8SVERSION/stable
microk8s stop
microk8s start
```

## NFS

```sh
# install
sudo apt install nfs-kernel-server

# To start the NFS server
sudo systemctl start nfs-kernel-server.service

# Make share
sudo mkdir -p /var/nfs/share
sudo chown -R nobody:nogroup /var/nfs/share

# configure the directories to be exported 
cat <<EOF | sudo tee /etc/exports
/var/nfs/share  *(rw,sync,no_subtree_check)
EOF

# Apply the new config via:
sudo exportfs -a
```

To test the NFS server

```sh
# From the gitlab server
ssh tgilkerson@192.168.50.11

# Install nfs client
sudo apt install nfs-common

mkdir /home/tgilkerson/temp/nfs/share
sudo mount 192.168.50.10:/var/nfs/share /home/tgilkerson/temp/nfs/share

cd /home/tgilkerson/temp/nfs/share/
ls -l  # You should see files from the zoo server!
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

```

## Httpbin

Deploy httpbin and use it to verify the Service Mesh

```sh
helmfile -i -f env/zoo/helmfile.yaml -l app=httpbin apply --skip-deps
```

## Cluster Load Balancer

Using Caddy as a reverse proxy in front of our cluster

Ref: [Caddy install docs](https://caddyserver.com/docs/install#debian-ubuntu-raspbian)

```sh
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
```

This section makes use of caddy's automatic https, see [local-https](https://caddyserver.com/docs/automatic-https#local-https)

Point your browser at  `http://192.168.50.10/` and see the default Caddy page.

Create `/etc/caddy/Caddyfile` and make it look like the following.

```sh
cat <<EOF | sudo tee /etc/caddy/Caddyfile
tonygilkerson.us {
  redir https://cafe.tonygilkerson.us
}

httpbin.tonygilkerson.us {
  tls internal
  reverse_proxy localhost:30080
}

cafe.tonygilkerson.us {
  tls internal
  reverse_proxy localhost:30080
}

notebook.tonygilkerson.us {
  tls internal
  reverse_proxy localhost:30080
}

hadev.tonygilkerson.us {
  tls internal
  reverse_proxy localhost:30080
}

# Could not get this to work, i will come back to it later
# For now use http://homeassistant.local:8123
# I think this is a docker networking thing
#
# ha.tonygilkerson.us {
#   tls internal
#   reverse_proxy 192.168.50.12:8123
# }


gitlab.tonygilkerson.us {
  tls internal
  reverse_proxy 192.168.50.11
}
EOF

# restart
sudo systemctl restart caddy


#
# Basic Auth example if you ever need it
#

# Replace MYPASSWORD (see cliperz search for "tonygilkerson.us cafe")
password=$(htpasswd -bnBC 10 "" MYPASSWORD | tr -d ':\n')

cat <<EOF | sudo tee /etc/caddy/Caddyfile
# Basic auth example
#   I am not using basic auth on most of the routes because
#   I only expose Caddy to the internet when it need to refresh TLS
#   NOTE: Caddy should not be exposed to the internet 
#         DNS entries resolve to local IPs 
foo.tonygilkerson.us {
  basic_auth { 
    tonygilkerson $password
  }
  reverse_proxy localhost:30080
}

EOF
```

Here is how DNS on Godaddy should look

| Type  | Name  | Data              | Comment                                    |
| ----- | ----- | ----------------- | ------------------------------------------ |
| ~~A~~ | ~~@~~ | ~~74.140.54.142~~ | Don't expose Caddy server to internet      |
| A     | @     | 192.168.50.10     | domain points to local Caddy server        |
| A     | *     | 192.168.50.10     | all subdomains point to local Caddy server |

For debugging.

```sh
# Run this and watch the logs
sudo caddy run --config /etc/caddy/Caddyfile

# status
systemctl status caddy

# Logs  
journalctl --no-pager -u caddy
journalctl -xeu caddy.service
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

## Gitlab

Ref

* [Gitlab install](https://about.gitlab.com/install)
* [Gitlab configuration](https://docs.gitlab.com/omnibus/settings/configuration.html)

For now I am going to install Gilab directly on Ubuntu outside of the cluster.  This is just the easiest.  

> Note: Gitlab needs port 80/443 on the host so it must live on a different server than the one where I have the Caddy reverse proxy.

```sh
# Install and configure the necessary dependencies
sudo apt update
sudo apt install -y curl openssh-server ca-certificates tzdata perl postfix

# Add the GitLab package repository and install the package
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash

sudo EXTERNAL_URL="http://192.168.50.11" apt-get install gitlab-ee
# List available versions: apt-cache madison gitlab-ee
# Specifiy version: sudo EXTERNAL_URL="https://gitlab.example.com" apt-get install gitlab-ee=16.2.3-ee.0
# Pin the version to limit auto-updates: sudo apt-mark hold gitlab-ee
# Show what packages are held back: sudo apt-mark showhold

# Open UI and reset the root password
user: root
password: <cat /etc/gitlab/initial_root_password>
url: http://192.168.50.11

# Install gitlab release-cli

```sh
sudo curl --location --output /usr/local/bin/release-cli "https://gitlab.com/api/v4/projects/gitlab-org%2Frelease-cli/packages/generic/release-cli/latest/release-cli-linux-amd64"
sudo chmod +x /usr/local/bin/release-cli
```      

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
sudo ufw enable

sudo apt install apache2-utils
sudo apt install iotop

# After executing the command the screen will turn off automatically every minute (if idle). 
setterm --blank 1

```

## PiHole

Reference: 
* [tutorial 2023](https://www.crosstalksolutions.com/the-worlds-greatest-pi-hole-and-unbound-tutorial-2023/)
* [youtube](https://www.youtube.com/watch?v=cE21YjuaB6o&t=267s)
* [pi-hole.net](https://pi-hole.net/)


```sh
# 
# Set static IP address
#

# find the IP assigned to it  via DHCP
ssh tgilkerson@<ip-address>

# Edit this file 
sudo vim /etc/dhcpcd.conf

# Make this section look like this
# Example static IP configuration:
#interface eth0
static ip_address=192.168.50.14/24
#static ip6_address=fd51:42f8:caae:d92e::ff/64
static routers=192.168.50.1
static domain_name_servers=192.168.50.14 8.8.8.8

# Reboot
sudo reboot

# Wait and log back in
ssh tgilkerson@192.168.50.14

# Install pihole
sudo su -
curl -sSL https://install.pi-hole.net | bash

# Change the Pi-hole Web GUI Admin Password
sudo pihole setpassword <same-as-tgilkerson-pwd>

# Update gravity each week (see Lists) 
sudo crontab -e # add the following line
0 3 * * 0 /usr/local/bin/pihole updateGravity
```

The web interface is [pihole web admin](http://192.168.50.14/admin)

### Lists

Some Blocking Resources – if you’re interested in taking a deeper dive into what block lists you can add to Pi-hole, here are some good resources:

* [The Best Pi-hole Blocklists](https://avoidthehack.com/best-pihole-blocklists) – `Avoidthehack.com` – This article does an excellent job of explaining the different types of block lists, and then lists a number of resources for lists in different categories of blocking.
* [The Firebog (blocklist collection)](https://firebog.net/) – This blocklist resource does an excellent job of providing sources of blocklists in multiple categories such as Suspicious, Advertising, Tracking & Telemetry, & Malicious. A good rule of thumb is to add one or two of these lists from each category to your Pi-hole.
* One more thing to point out – there is a list of commonly whitelisted domains over at [Pi-hole.net](Pi-hole.net). If you’re having issues with a particular website or service (say Spotify or Xbox functionality for instance), go see if there are resources for whitelisting that particular service on that page – it may save you a lot of headache.

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
make docServe
open http://127.0.0.1:8000/
```

Publish

```sh
make docPub
open https://tonygilkerson.github.io/cafe/
```
