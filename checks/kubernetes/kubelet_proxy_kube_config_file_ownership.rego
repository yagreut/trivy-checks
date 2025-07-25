# METADATA
# title: "if proxy kubeconfig file exists ensure ownership is set to root:root"
# description: "If kube-proxy is running, ensure that the file ownership of its kubeconfig file is set to root:root."
# scope: package
# schemas:
#   - input: schema["kubernetes"]
# related_resources:
#   - https://www.cisecurity.org/benchmark/kubernetes
# custom:
#   id: KCV-0072
#   aliases:
#     - AVD-KCV-0072
#     - KCV0072
#     - ensure-proxy-kubeconfig-ownership-set-root:root-if-exist
#   long_id: kubernetes-ensure-proxy-kubeconfig-ownership-set-root:root-if-exist
#   severity: HIGH
#   recommended_action: "Change the proxy kubeconfig file <path><filename> ownership to root:root if exist"
#   input:
#     selector:
#       - type: kubernetes
#         subtypes:
#           - kind: nodeinfo
package builtin.kubernetes.KCV0072

import rego.v1

types := ["master", "worker"]

validate_kube_config_file_ownership(sp) := {"kubeconfigFileExistsOwnership": violation} if {
	sp.kind == "NodeInfo"
	sp.type == types[_]
	count(sp.info.kubeconfigFileExistsOwnership) > 0
	violation := {ownership | ownership = sp.info.kubeconfigFileExistsOwnership.values[_]; ownership != "root:root"}
	count(violation) > 0
}

deny contains res if {
	output := validate_kube_config_file_ownership(input)
	msg := "Ensure proxy kubeconfig file ownership is set to root:root if exists"
	res := result.new(msg, output)
}
