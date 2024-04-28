# Cert Manager

## CSI Driver

To test the CSI driver, crate the following in your personal workspace

```sh
# Create selfsigned Issuer
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: test-selfsigned-issuer
spec:
  selfSigned: {}
---
# Create selfsigned CA
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test-selfsigned-ca
spec:
  isCA: true
  commonName: test-selfsigned-ca
  secretName: test-root-secret
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: test-selfsigned-issuer
    kind: Issuer
    group: cert-manager.io
---
# Create CA Issuer
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: test-ca-issuer
spec:
  ca:
    secretName: test-root-secret
---
# Test pod that uses the CSI driver
apiVersion: v1
kind: Pod
metadata:
  name: test-csi-app
  labels:
    app: test-csi-app
spec:
  containers:
    - name: test-frontend
      image: busybox
      volumeMounts:
      - mountPath: "/tls"
        name: tls
      command: [ "sleep", "1000000" ]
  volumes:
    - name: tls
      csi:
        readOnly: true
        driver: csi.cert-manager.io
        volumeAttributes:
          csi.cert-manager.io/issuer-name: test-ca-issuer
          csi.cert-manager.io/dns-names: ${POD_NAME}.${POD_NAMESPACE}.svc.cluster.local
EOF
```

Now you should be able to shell into the pod and see a tls folder

```sh
/tls # ls -l
total 0
lrwxrwxrwx    1 root     root            13 May  4 17:11 ca.crt -> ..data/ca.crt
lrwxrwxrwx    1 root     root            14 May  4 17:11 tls.crt -> ..data/tls.crt
lrwxrwxrwx    1 root     root            14 May  4 17:11 tls.key -> ..data/tls.key
```

cleanup

```sh
kubectl delete pod test-csi-app
kubectl delete issuer test-ca-issuer
kubectl delete certificate test-selfsigned-ca
kubectl delete issuer test-selfsigned-issuer
```
