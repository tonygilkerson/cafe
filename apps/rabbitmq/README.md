# rabbitmq

## Install/Upgrade

```sh
# Deploy
helmfile -f env/zoo/helmfile.yaml -l app=rabbitmq apply --skip-deps
```

## Access The Management UI

see [rabbitmq docs](https://www.rabbitmq.com/kubernetes/operator/quickstart-operator)

```sh
username="$(kubectl -n rabbitmq get secret zoomq-default-user -o jsonpath='{.data.username}' | base64 --decode)"
echo "username: $username"
password="$(kubectl -n rabbitmq get secret zoomq-default-user -o jsonpath='{.data.password}' | base64 --decode)"
echo "password: $password"

kubectl -n rabbitmq port-forward "service/zoomq" 15672

# Open UI (use username and password above to login)
open http://localhost:15672/
```
