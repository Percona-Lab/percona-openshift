# Install helm in Google Cloud:

    kubectl create serviceaccount --namespace kube-system tiller
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller
# Install Helm in OpenShift

For the details see https://blog.openshift.com/getting-started-helm-openshift/

Commands:
```
oc new-project tiller
curl -s https://storage.googleapis.com/kubernetes-helm/helm-v2.9.0-linux-amd64.tar.gz | tar xz
$ cd linux-amd64
$ ./helm init --client-only
oc process -f https://github.com/openshift/origin/raw/master/examples/helm/tiller-template.yaml -p TILLER_NAMESPACE="tiller" -p HELM_VERSION=v2.9.0 | oc create -f -

oc new-project myapp
oc policy add-role-to-user edit "system:serviceaccount:tiller:tiller"
```
