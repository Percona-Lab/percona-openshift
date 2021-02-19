# Percona Monitoring and Management Helm chart
## 🛑🛑🛑 It is unsupported software, please consider using the officially supported method of installing PMM Server - https://www.percona.com/doc/percona-monitoring-and-management/2.x/setting-up/index.html

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
| `service.port`             | Listening port for the Kubernetes Service | 443                                                  |
| `service.loadBalancerIP`   | IP address for the public access    | ""                                                         |
| `prometheus.configMap.name`   | Name of k8s configMap with scrape_configs    | ""                                                         |
| `ingress.enabled`          | Enable the [Kubernetes Ingress type](https://v1-18.docs.kubernetes.io/docs/concepts/services-networking/ingress/#the-ingress-resource) | ""                                                         |
| `ingress.annotations`      | Ingress Annotations  | `false`                                                         |
| `ingress.rules[].host` | Ingress Host from multiple hosts | `` |
| `ingress.rules[].path` | Ingress Path from multiple hosts | `/` |
| `ingress.rules[].pathType` | Ingress Path Type from multiple hosts | `` |
| `ingress.path`             | Ingress Path         | `/`                                                         |
| `ingress.pathType`         | Ingress Path Type [Kubernetes Ingress PathType](https://v1-18.docs.kubernetes.io/docs/concepts/services-networking/ingress/#path-types)   | ``                                                         |
| `ingress.host`             | Ingress Host   | ``                                                         |
| `ingress.tls`              | Configure Ingress TLS options [Kubernetes Ingress TLS](https://v1-18.docs.kubernetes.io/docs/concepts/services-networking/ingress/#tls)   | ""                                                         |
| `ingress.labels`           | Ingress Labels   | ""                                                         |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

