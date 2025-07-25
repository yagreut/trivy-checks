# METADATA
# title: "Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate"
# description: "Setup TLS connection on the API server."
# scope: package
# schemas:
#   - input: schema["kubernetes"]
# related_resources:
#   - https://www.cisecurity.org/benchmark/kubernetes
# custom:
#   id: KCV-0027
#   aliases:
#     - AVD-KCV-0027
#     - KCV0027
#     - ensure-tls-cert-file-and-tls-private-key-file-arguments-are-set-as-appropriate
#   long_id: kubernetes-ensure-tls-cert-file-and-tls-private-key-file-arguments-are-set-as-appropriate
#   severity: LOW
#   recommended_action: "Follow the Kubernetes documentation and set up the TLS connection on the apiserver. Then, edit the API server pod specification file /etc/kubernetes/manifests/kube-apiserver.yaml on the master node and set the TLS certificate and private key file parameters."
#   input:
#     selector:
#       - type: kubernetes
package builtin.kubernetes.KCV0027

import rego.v1

import data.lib.kubernetes

check_flag(container) if {
	kubernetes.command_has_flag(container.command, "--tls-cert-file")
	kubernetes.command_has_flag(container.command, "--tls-private-key-file")
}

check_flag(container) if {
	kubernetes.command_has_flag(container.args, "--tls-cert-file")
	kubernetes.command_has_flag(container.args, "--tls-private-key-file")
}

deny contains res if {
	container := kubernetes.containers[_]
	kubernetes.is_apiserver(container)
	not check_flag(container)
	msg := "Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate"
	res := result.new(msg, container)
}
