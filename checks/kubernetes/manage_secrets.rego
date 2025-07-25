# METADATA
# title: "Manage secrets"
# description: "Viewing secrets at the cluster-scope is akin to cluster-admin in most clusters as there are typically at least one service accounts (their token stored in a secret) bound to cluster-admin directly or a role/clusterrole that gives similar permissions."
# scope: package
# schemas:
#   - input: schema["kubernetes"]
# related_resources:
#   - https://kubernetes.io/docs/concepts/security/rbac-good-practices/
# custom:
#   id: KSV-0041
#   aliases:
#     - AVD-KSV-0041
#     - KSV041
#     - no-manage-secrets
#   long_id: kubernetes-no-manage-secrets
#   severity: CRITICAL
#   recommended_actions: "Manage secrets are not allowed. Remove resource 'secrets' from cluster role"
#   input:
#     selector:
#       - type: kubernetes
#         subtypes:
#           - kind: clusterrole
package builtin.kubernetes.KSV041

import rego.v1

import data.lib.kubernetes

readVerbs := ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection", "impersonate", "*"]

readKinds := ["ClusterRole"]

resourceManageSecret contains input.rules[ru] if {
	some ru, r, v
	input.kind == readKinds[_]
	input.rules[ru].resources[r] == "secrets"
	input.rules[ru].verbs[v] == readVerbs[_]
}

deny contains res if {
	badRule := resourceManageSecret[_]
	msg := kubernetes.format(sprintf("%s '%s' shouldn't have access to manage resource 'secrets'", [kubernetes.kind, kubernetes.name]))
	res := result.new(msg, badRule)
}
