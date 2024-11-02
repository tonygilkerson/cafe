# OAuth2 Proxy

## DEVTODO - remove auth2-proxy

## Existing Secrets

Create existing secret so OAuth2-Proxy cn talk GCP

```sh
source .env

kubectl apply -f -<<EOF 
apiVersion: v1
kind: Secret
metadata:
  name: oauth2-secret
  namespace: oauth2-proxy
stringData:
  client-id: "$GCP_CLIENT_ID" 
  client-secret: "$GCP_CLIENT_SECRET"
  cookie-secret: "$OAUTH2_COOKIE_SECRET"
EOF
```
