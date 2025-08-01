# METADATA
# title: "Ensure that the --encryption-provider-config argument is set as appropriate"
# description: "Encrypt etcd key-value store."
# scope: package
# schemas:
#   - input: schema["kubernetes"]
# related_resources:
#   - https://www.cisecurity.org/benchmark/kubernetes
# custom:
#   id: KCV-0030
#   aliases:
#     - AVD-KCV-0030
#     - KCV0030
#     - Ensure that the --encryption-provider-config argument is set as appropriate
#   long_id: kubernetes-Ensure that the --encryption-provider-config argument is set as appropriate
#   severity: LOW
#   recommended_action: "Follow the Kubernetes documentation and configure a EncryptionConfig file. Then, edit the API server pod specification file /etc/kubernetes/manifests/kube-apiserver.yaml on the master node and set the --encryption-provider-config parameter to the path of that file"
#   input:
#     selector:
#       - type: kubernetes
package builtin.kubernetes.KCV0030

import rego.v1

import data.lib.kubernetes

check_flag(container) if {
	kubernetes.command_has_flag(container.command, "--encryption-provider-config")
}

check_flag(container) if {
	kubernetes.command_has_flag(container.args, "--encryption-provider-config")
}

deny contains res if {
	container := kubernetes.containers[_]
	kubernetes.is_apiserver(container)
	not check_flag(container)
	msg := "Ensure that the --encryption-provider-config argument is set as appropriate"
	res := result.new(msg, container)
}
