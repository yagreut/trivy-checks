# METADATA
# title: Access to host IPC namespace
# description: Sharing the host’s IPC namespace allows container processes to communicate with processes on the host.
# scope: package
# related_resources:
#   - https://kubernetes.io/docs/concepts/security/pod-security-standards/#baseline
# schemas:
#   - input: schema["kubernetes"]
# custom:
#   id: KSV-0008
#   aliases:
#     - AVD-KSV-0008
#     - KSV008
#     - no-shared-ipc-namespace
#   long_id: kubernetes-no-shared-ipc-namespace
#   severity: HIGH
#   recommended_action: Do not set 'spec.template.spec.hostIPC' to true.
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
#   examples: checks/kubernetes/host_ipc.yaml
package builtin.kubernetes.KSV008

import rego.v1

import data.lib.kubernetes

default failHostIPC := false

# failHostIPC is true if spec.hostIPC is set to true (on all resources)
failHostIPC if {
	kubernetes.host_ipcs[_] == true
}

deny contains res if {
	failHostIPC
	msg := kubernetes.format(sprintf("%s '%s' should not set 'spec.template.spec.hostIPC' to true", [kubernetes.kind, kubernetes.name]))
	res := result.new(msg, input.spec)
}
