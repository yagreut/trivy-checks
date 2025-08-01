# METADATA
# title: "Do not allow users in a rolebinding to add other users to their rolebindings"
# description: "Check whether role permits allowing users in a rolebinding to add other users to their rolebindings"
# scope: package
# schemas:
#   - input: schema["kubernetes"]
# related_resources:
#   - https://kubernetes.io/docs/concepts/security/rbac-good-practices/
# custom:
#   id: KSV-0055
#   aliases:
#     - AVD-KSV-0055
#     - KSV055
#     - view-all-secrets
#   long_id: kubernetes-view-all-secrets
#   severity: LOW
#   recommended_action: "Create a role which does not permit allowing users in a rolebinding to add other users to their rolebindings if not needed"
#   input:
#     selector:
#       - type: kubernetes
package builtin.kubernetes.KSV055

import rego.v1

readKinds := ["Role", "ClusterRole"]

allowing_users_rolebinding_add_other_users_their_rolebindings contains input.rules[ru] if {
	some ru
	input.kind == readKinds[_]
	input.rules[ru].apiGroups[_] == "*"
	input.rules[ru].resources[_] == "rolebindings"
	input.rules[ru].verbs[_] == "get"
	input.rules[ru].verbs[_] == "patch"
}

deny contains res if {
	badRule := allowing_users_rolebinding_add_other_users_their_rolebindings[_]
	msg := "Role permits allowing users in a rolebinding to add other users to their rolebindings"
	res := result.new(msg, badRule)
}
