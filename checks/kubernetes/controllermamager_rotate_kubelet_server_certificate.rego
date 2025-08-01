# METADATA
# title: "Ensure that the RotateKubeletServerCertificate argument is set to true"
# description: "Enable kubelet server certificate rotation on controller-manager."
# scope: package
# schemas:
#   - input: schema["kubernetes"]
# related_resources:
#   - https://www.cisecurity.org/benchmark/kubernetes
# custom:
#   id: KCV-0038
#   aliases:
#     - AVD-KCV-0038
#     - KCV0038
#     - Ensure that the RotateKubeletServerCertificate argument is set to true
#   long_id: kubernetes-Ensure that the RotateKubeletServerCertificate argument is set to true
#   severity: LOW
#   recommended_action: "Edit the Controller Manager pod specification file /etc/kubernetes/manifests/kube-controller-manager.yaml on the Control Plane node and set the --feature-gates parameter to include RotateKubeletServerCertificate=true ."
#   input:
#     selector:
#       - type: kubernetes
package builtin.kubernetes.KCV0038

import rego.v1

import data.lib.kubernetes

checkFlag(container) if {
	kubernetes.command_has_flag(container.command, "RotateKubeletServerCertificate=true")
}

checkFlag(container) if {
	kubernetes.command_has_flag(container.args, "RotateKubeletServerCertificate=true")
}

deny contains res if {
	container := kubernetes.containers[_]
	kubernetes.is_controllermanager(container)
	not checkFlag(container)
	msg := "Ensure that the RotateKubeletServerCertificate argument is set to true"
	res := result.new(msg, container)
}
