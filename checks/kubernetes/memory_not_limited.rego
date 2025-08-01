# METADATA
# title: "Memory not limited"
# description: "Enforcing memory limits prevents DoS via resource exhaustion."
# scope: package
# schemas:
#   - input: schema["kubernetes"]
# related_resources:
#   - https://kubesec.io/basics/containers-resources-limits-memory/
# custom:
#   id: KSV-0018
#   aliases:
#     - AVD-KSV-0018
#     - KSV018
#     - limit-memory
#   long_id: kubernetes-limit-memory
#   severity: LOW
#   recommended_action: "Set a limit value under 'containers[].resources.limits.memory'."
#   input:
#     selector:
#       - type: kubernetes
#         subtypes:
#           - kind: pod
#           - kind: replicaset
#           - kind: replicationcontroller
#           - kind: deployment
#           - kind: deploymentconfig
#           - kind: statefulset
#           - kind: daemonset
#           - kind: cronjob
#           - kind: job
package builtin.kubernetes.KSV018

import rego.v1

import data.lib.kubernetes
import data.lib.utils

default failLimitsMemory := false

# getLimitsMemoryContainers returns all containers which have set resources.limits.memory
getLimitsMemoryContainers contains container if {
	container := kubernetes.containers[_]
	utils.has_key(container.resources.limits, "memory")
}

# getNoLimitsMemoryContainers returns all containers which have not set
# resources.limits.memory
getNoLimitsMemoryContainers contains container if {
	container := kubernetes.containers[_]
	not getLimitsMemoryContainers[container]
}

deny contains res if {
	output := getNoLimitsMemoryContainers[_]
	msg := kubernetes.format(sprintf("Container '%s' of %s '%s' should set 'resources.limits.memory'", [output.name, kubernetes.kind, kubernetes.name]))
	res := result.new(msg, output)
}
