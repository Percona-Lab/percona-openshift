# Percona Monitoring and Management Helm chart

Percona Monitoring and Management (PMM) is an open-source platform for managing and monitoring MySQL and MongoDB performance. It is developed by Percona in collaboration with experts in the field of managed database services, support and consulting.

PMM is a free and open-source solution that you can run in your own environment for maximum security and reliability. It provides thorough time-based analysis for MySQL and MongoDB servers to ensure that your data works as efficiently as possible.

## Prerequisites

- Kubernetes 1.9+ / OpenShift 3.9 with Beta APIs enabled
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `monitoring`:

```bash
$ helm install --name monitoring .
```

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `monitoring` deployment:

```bash
$ helm delete --purge monitoring
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the Percona chart and their default values.

| Parameter                  | Description                         | Default                                                    |
| -----------------------    | ----------------------------------- | ---------------------------------------------------------- |
| `imageTag`                 | `percona/pmm-server` image          | Most recent release                                        |
| `imagePullPolicy`          | Image pull policy                   | `Always`                                                   |
| `persistence.enabled`      | Create a volume to store data       | true                                                       |
| `persistence.size`         | Size of persistent volume claim     | 8Gi RW                                                     |
| `persistence.storageClass` | Type of persistent volume claim     | nil  (uses alpha storage class annotation)                 |
| `persistence.accessMode`   | ReadWriteOnce or ReadOnly           | ReadWriteOnce                                              |
| `resources`                | CPU/Memory resource requests/limits | Memory: `1Gi`, CPU: `0.5`                                  |
| `service.type`             | Option specifying the [Kubernetes Service type](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types) to be used | ""                                                         |
| `service.loadBalancerIP`   | IP address for the public access    | ""                                                         |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. 

