# percona-openshift
Set of scripts to run Percona software in OpenShift / Kubernetes / Google Cloud Kubernetes Engine

## MySQL Passwords
Before deployments you need to create passwords (secrets) which will be used to access Percona Server / Percona XtraDB Cluster.
We provide file https://github.com/Percona-Lab/percona-openshift/blob/master/deploy/secret.yaml as an example. **Please use your own secure passwords!**

Use `base64` to encode a password for `secret.yaml` : `echo -n 'securepassword' | base64`.

Used `base64 -d` to decode a password from `secret.yaml` : `echo YmFja3VwX3Bhc3N3b3Jk | base64 -d`.


## Considerations
The proposed depoyments were tested on Kubernetes 1.9 / OpenShift Origin 3.9. The earlier versions may not work.

The deployments assume you have a default `StorageClass` which will provide Persistent Volumes. If not, you need to create `PersistentVolume` manually.

## Deployments

### Master with N Slaves

We use `replica-set.yaml` to create a master with multiple slaves. The total amount of nodes is defined in `replicas: 2`.

To scale an existing depoyment you can use `kubectl scale --replicas=5 statefulsets/rsnode` - this will scale the total amount of nodes to 5 (That is 1 master and 4 slaves)

#### ProxySQL service over Percona ReplicaSet

Deployment `proxysql-replicaset.yaml` will create ProxySQL service and automatically configure to handle a traffic to Percona XtraDB Cluster service.
The service to handled is defined in line: `- -service=replicaset1`

### Backups

It is possible to make a backup from a running master or slave.
- Create a backup volume. Example `kubectl create -f backup-volume.yaml`
- Run a backup job. Example `kubectl create -f xtrabackup-job.yaml`. **Important** Change `NODE_NAME` to a valid `podname.service` address as a source of backup.

TODO:
- [X] Create ProxySQL service to handle master-slaves deployments
- [ ] Encrypted connections from ProxySQL to MySQL servers
- [ ] Encrypted connections from clients to MySQL servers


### Percona XtraDB Cluster N nodes
Deployment `pxc.yaml` will create a StatefulSet with N nodes (defined in `replicas: 3`)
Pay attention to the service name, defined in `name: pxccluster1`

TODO:
- [ ] Encrypted connections from clients to PXC Nodes
- [ ] Encrypted connections between PXC Nodes

### ProxySQL service over Percona XtraDB Cluster

Deployment `proxysql-pxc.yaml` will create ProxySQL service and automatically configure to handle a traffic to Percona XtraDB Cluster service.
The service to handled is defined in line: `- -service=pxccluster1`

TODO:
- [ ] Encrypted connections from ProxySQL to PXC Nodes

### A custom MySQL config. 
The deployments support a custom MySQL config.
You can customize `mysql-configmap.yaml` to add any configuration lines you may need.
Next command will create a ConfigMap: `kubectl create -f mysql-configmap.yaml`. The ConfigMap must be created before any deployments.

### Further work
- [ ] Provide depoloyments for PMM Server
- [ ] Configure nodes with PMM Client
- [ ] Provide a guidance how to create / restore from backups


## Cheatsheet

For OpenShift replace `kubectl` with `oc`

* List available nodes `kubectl get nodes`
* List running pods `kubectl get pods`
* Create deployment `kubectl create -f replica-set.yaml`
* Delete deployment `kubectl delete -f replica-set.yaml`
* Watch pods changing during deployment `watch kubectl get pods`
* Diagnostic about a pod, in case of failure `kubectl describe po/rsnode-0`
* Logs from pods `kubectl logs -f rsnode-0`
* Logs from the particular container in pod `kubectl logs -f rsnode-1 -c clone-mysql`
* Access to bash in container ` kubectl exec rsnode-0 -it -- bash`
* Access to mysql in container `kubectl exec rsnode-0 -it -- mysql -uroot -proot_password`
* Access to proxysql admin `kubectl exec proxysql-0 -it -- mysql  -uadmin -padmin -h127.0.0.1 -P6032`
