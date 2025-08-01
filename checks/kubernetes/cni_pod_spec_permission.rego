# METADATA
# title: "Ensure that the container network interface file permissions are set to 600 or more restrictive"
# description: "Ensure that the container network interface file has permissions of 600 or more restrictive."
# scope: package
# schemas:
# - input: schema["kubernetes"]
# related_resources:
# - https://www.cisecurity.org/benchmark/kubernetes
# custom:
#   id: KCV-0056
#   aliases:
#     - AVD-KCV-0056
#     - KCV0056
#     - ensure-container-network-interface-file-permissions-set
#   severity: HIGH
#   short_code: ensure-container-network-interface-file-permissions-set-600-or-more-restrictive
#   recommended_action: "Change the container network interface file path/to/cni/files permissions of 600 or more restrictive "
#   input:
#     selector:
#     - type: kubernetes
#       subtypes:
#         - kind: nodeinfo
package builtin.kubernetes.KCV0056

import rego.v1

validate_cni_permission(sp) := {"containerNetworkInterfaceFilePermissions": violation} if {
	sp.kind == "NodeInfo"
	sp.type == "master"
	violation := {permission | permission = sp.info.containerNetworkInterfaceFilePermissions.values[_]; permission > 600}
	count(violation) > 0
}

deny contains res if {
	output := validate_cni_permission(input)
	msg := "Ensure that the Container Network Interface specification file permissions are set to 600 or more restrictive"
	res := result.new(msg, output)
}
