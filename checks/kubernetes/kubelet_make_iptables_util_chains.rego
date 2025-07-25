# METADATA
# title: "Ensure that the --make-iptables-util-chains argument is set to true"
# description: "Allow Kubelet to manage iptables."
# scope: package
# schemas:
#   - input: schema["kubernetes"]
# related_resources:
#   - https://www.cisecurity.org/benchmark/kubernetes
# custom:
#   id: KCV-0084
#   aliases:
#     - AVD-KCV-0084
#     - KCV0084
#     - ensure-make-iptables-util-chains-argument-set-true
#   long_id: kubernetes-ensure-make-iptables-util-chains-argument-set-true
#   severity: HIGH
#   recommended_action: "If using a Kubelet config file, edit the file to set makeIPTablesUtilChains: true"
#   input:
#     selector:
#       - type: kubernetes
#         subtypes:
#           - kind: nodeinfo
package builtin.kubernetes.KCV0084

import rego.v1

types := ["master", "worker"]

validate_kubelet_iptables_util_chains_set(sp) := {"kubeletMakeIptablesUtilChainsArgumentSet": violation} if {
	sp.kind == "NodeInfo"
	sp.type == types[_]
	violation := {iptables_util_chains | iptables_util_chains = sp.info.kubeletMakeIptablesUtilChainsArgumentSet.values[_]; not iptables_util_chains == "true"}
	count(violation) > 0
}

deny contains res if {
	output := validate_kubelet_iptables_util_chains_set(input)
	msg := "Ensure that the --make-iptables-util-chains argument is set to true"
	res := result.new(msg, output)
}
