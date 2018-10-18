package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

type PerconaXtradbClusterList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata"`
	Items           []PerconaXtradbCluster `json:"items"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

type PerconaXtradbCluster struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata"`
	Spec              PerconaXtradbClusterSpec   `json:"spec"`
	Status            PerconaXtradbClusterStatus `json:"status,omitempty"`
}

type PerconaXtradbClusterSpec struct {
	Size   int32                        `json:"size"`
	Image  string                       `json:"image,omitempty"`
	RunGID int64                        `json:"runGid,omitempty"`
	RunUID int64                        `json:"runUid,omitempty"`
	PXC    *PerconaXtradbClusterPXCSpec `json:"pxc,omitempty"`
}
type PerconaXtradbClusterPXCSpec struct {
	Port int32 `json:"port,omitempty"`
}

type PerconaXtradbClusterStatus struct {
	Nodes []string `json:"nodes"`
}
