package stub

import (
	"context"

	"github.com/Percona-Lab/percona-openshift/pxc-operator/pkg/apis/pxc/v1"

	"github.com/operator-framework/operator-sdk/pkg/sdk"
	"github.com/sirupsen/logrus"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func NewHandler() sdk.Handler {
	return &Handler{}
}

type Handler struct {
	// Fill me
}

func (h *Handler) Handle(ctx context.Context, event sdk.Event) error {
	switch o := event.Object.(type) {
	case *v1.PerconaXtradbCluster:
		// Ignore the delete event since the garbage collector will clean up all secondary resources for the CR
		// All secondary resources must have the CR set as their OwnerReference for this to be the case
		if event.Deleted {
			return nil
		}

		err := sdk.Create(newStatefulSet(o))
		if err != nil && !errors.IsAlreadyExists(err) {
			logrus.Errorf("failed to create newStatefulSet: %v", err)
			return err
		}
		err = sdk.Create(newService(o))
		if err != nil && !errors.IsAlreadyExists(err) {
			logrus.Errorf("failed to create PXC Service: %v", err)
			return err
		}
	}
	return nil
}

func newService(cr *v1.PerconaXtradbCluster) *corev1.Service {
	ls := labelsForPXC(cr.Name)
	return &corev1.Service{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "v1",
			Kind:       "Service",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "pxccluster1", //cr.Name,
			Namespace: cr.Namespace,
		},
		Spec: corev1.ServiceSpec{
			Ports: []corev1.ServicePort{
				{
					Port: 3306,
					Name: "mysql-port",
				},
			},
			ClusterIP: "None",
			Selector:  ls,
		},
	}
}

func newStatefulSet(cr *v1.PerconaXtradbCluster) *appsv1.StatefulSet {
	ls := labelsForPXC(cr.Name)
	replicas := cr.Spec.Size

	return &appsv1.StatefulSet{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "apps/v1beta1",
			Kind:       "StatefulSet",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "pxcnode", //cr.Name,
			Namespace: cr.Namespace,
		},
		Spec: appsv1.StatefulSetSpec{
			Replicas: &replicas,
			Selector: &metav1.LabelSelector{
				MatchLabels: ls,
			},
			Template: corev1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: ls,
				},
				Spec: corev1.PodSpec{
					DNSPolicy: corev1.DNSClusterFirstWithHostNet,
					Containers: []corev1.Container{{
						Name:    "pxc-openshift",
						Image:   cr.Spec.Image,
						Command: []string{},
						Ports: []corev1.ContainerPort{{
							ContainerPort: 3306,
							Name:          "mysql-port",
						}},
						VolumeMounts: []corev1.VolumeMount{
							{
								Name:      "datadir",
								MountPath: "/var/lib/mysql",
								SubPath:   "data",
							},
							{
								Name:      "config-volume",
								MountPath: "/etc/mysql/conf.d/",
							},
						},
						Env: []corev1.EnvVar{
							{
								Name:  "MYSQL_FORCE_INIT",
								Value: "1",
							},
							{
								Name: "MYSQL_ROOT_PASSWORD",
								ValueFrom: &corev1.EnvVarSource{
									SecretKeyRef: secretKeySelector("mysql-passwords", "root"),
								},
							},
							{
								Name: "XTRABACKUP_PASSWORD",
								ValueFrom: &corev1.EnvVarSource{
									SecretKeyRef: secretKeySelector("mysql-passwords", "xtrabackup"),
								},
							},
							{
								Name: "MONITOR_PASSWORD",
								ValueFrom: &corev1.EnvVarSource{
									SecretKeyRef: secretKeySelector("mysql-passwords", "monitor"),
								},
							},
							{
								Name: "CLUSTERCHECK_PASSWORD",
								ValueFrom: &corev1.EnvVarSource{
									SecretKeyRef: secretKeySelector("mysql-passwords", "clustercheck"),
								},
							},
						},
					}},
				},
			},
			VolumeClaimTemplates: []corev1.PersistentVolumeClaim{
				{
					ObjectMeta: metav1.ObjectMeta{
						Name: "datadir",
					},
					Spec: corev1.PersistentVolumeClaimSpec{
						AccessModes: []corev1.PersistentVolumeAccessMode{
							corev1.ReadWriteOnce,
						},
						Resources: corev1.ResourceRequirements{
							Requests: corev1.ResourceList{
								corev1.ResourceStorage: *resource.NewQuantity(8, resource.DecimalSI),
							},
						},
						Selector: &metav1.LabelSelector{
							MatchLabels: ls,
						},
					},
				},
			},
		},
	}
}

func secretKeySelector(name, key string) *corev1.SecretKeySelector {
	evs := &corev1.SecretKeySelector{}
	evs.Name = name
	evs.Key = key

	return evs
}

func labelsForPXC(name string) map[string]string {
	return map[string]string{"app": "pxc-openshift", "pxc_cr": name}
}
