# PXC Operator

```sh
operator-sdk new pxc-operator --api-version=pxc.percona.com/v1 --kind=PerconaXtradbCluster --skip-git-init
```

```sh
kubectl create -f deploy/rbac.yaml
kubectl create -f deploy/crd.yaml
kubectl create -f deploy/operator.yaml
```

```sh
kubectl delete -f deploy/operator.yaml
kubectl delete -f deploy/crd.yaml
kubectl delete -f deploy/rbac.yaml
```

```sh
OPERATOR_NAME=pxc-operator WATCH_NAMESPACE="andrew-pxc" operator-sdk up local
kubectl apply -f deploy/cr.yaml
```

```sh
kubectl delete -f deploy/cr.yaml
```