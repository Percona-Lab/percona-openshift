package stub

import (
	"context"

	"github.com/Percona-Lab/percona-openshift/pxc-operator/pkg/apis/pxc/v1"

	"github.com/operator-framework/operator-sdk/pkg/sdk"
	"github.com/sirupsen/logrus"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime/schema"
)

func NewHandler() sdk.Handler {
	return &Handler{}
}

type Handler struct {
	// Fill me
}

func (h *Handler) Handle(ctx context.Context, event sdk.Event) error {
	// logrus.Infof("New event %#v / %v", event.Object, event.Deleted)

	switch o := event.Object.(type) {
	case *v1.PerconaXtradbCluster:
		// err := sdk.Create(newPXCPod(o))
		err := sdk.Create(deploymentForPXC(o))
		if err != nil && !errors.IsAlreadyExists(err) {
			logrus.Errorf("failed to create busybox pod : %v", err)
			return err
		}
	}
	return nil
}

// newPXCPod creates a PXC pod
func newPXCPod(cr *v1.PerconaXtradbCluster) *corev1.Pod {
	labels := map[string]string{
		"app": "pxc-openshift",
	}
	return &corev1.Pod{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Pod",
			APIVersion: "v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "pxc-openshift",
			Namespace: cr.Namespace,
			OwnerReferences: []metav1.OwnerReference{
				*metav1.NewControllerRef(cr, schema.GroupVersionKind{
					Group:   v1.SchemeGroupVersion.Group,
					Version: v1.SchemeGroupVersion.Version,
					Kind:    "PerconaXtradbCluster",
				}),
			},
			Labels: labels,
		},
		Spec: corev1.PodSpec{
			Containers: []corev1.Container{
				{
					Name:    "pxc-openshift",
					Image:   cr.Spec.Image,
					Command: []string{},
				},
			},
		},
	}
}

func deploymentForPXC(cr *v1.PerconaXtradbCluster) *appsv1.Deployment {
	ls := labelsForPXC(cr.Name)
	replicas := cr.Spec.Size

	dep := &appsv1.Deployment{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "apps/v1",
			Kind:       "Deployment",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      cr.Name,
			Namespace: cr.Namespace,
		},
		Spec: appsv1.DeploymentSpec{
			Replicas: &replicas,
			Selector: &metav1.LabelSelector{
				MatchLabels: ls,
			},
			Template: corev1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: ls,
				},
				Spec: corev1.PodSpec{
					Containers: []corev1.Container{{
						Name:    "pxc-openshift",
						Image:   cr.Spec.Image,
						Command: []string{},
						Ports: []corev1.ContainerPort{{
							ContainerPort: 3306,
							Name:          "mysql-port",
						}},
					}},
				},
			},
		},
	}
	return dep
}

func labelsForPXC(name string) map[string]string {
	return map[string]string{"app": "pxc-openshift", "pxc_cr": name}
}
