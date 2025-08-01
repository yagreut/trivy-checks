# METADATA
# title: "Manage EKS IAM Auth ConfigMap"
# description: "Ability to add AWS IAM to RBAC bindings via special EKS configmap."
# scope: package
# schemas:
#   - input: schema["kubernetes"]
# related_resources:
#   - https://kubernetes.io/docs/concepts/security/rbac-good-practices/
# custom:
#   id: KSV-0115
#   aliases:
#     - AVD-KSV-0115
#     - KSV115
#     - eks-iam-configmap
#   long_id: kubernetes-eks-iam-configmap
#   severity: CRITICAL
#   recommended_actions: "Remove write permission verbs for resource 'configmaps' named 'aws-auth'"
#   input:
#     selector:
#       - type: kubernetes
#         subtypes:
#           - kind: clusterrole
#           - kind: role
package builtin.kubernetes.KSV115

import rego.v1

import data.lib.kubernetes

readVerbs := ["create", "update", "patch", "delete", "deletecollection", "impersonate", "*"]

readKinds := ["Role", "ClusterRole"]

readResource := "configmaps"

resourceName := "aws-auth"

manageEKSIAMAuthConfigmap contains input.rules[ru] if {
	some ru, r, v
	input.kind == readKinds[_]
	input.rules[ru].resources[r] == readResource
	input.rules[ru].verbs[v] == readVerbs[_]
	input.rules[ru].resourceNames[rn] == resourceName
}

deny contains res if {
	badRule := manageEKSIAMAuthConfigmap[_]
	msg := kubernetes.format(sprintf("%s '%s' should not have access to resource '%s' named '%s' for verbs %s", [kubernetes.kind, kubernetes.name, readResource, resourceName, readVerbs]))
	res := result.new(msg, badRule)
}
