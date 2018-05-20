ocversion=`oc version|grep openshift|cut -d ' ' -f 2 2>/dev/null`
kubeversion=`kubectl version 2>/dev/null`

oc create -f secret.yaml && oc create -f mysql-configmap.yaml
oc create -f pxc.yaml && oc create -f proxysql-pxc-oc.yaml 
