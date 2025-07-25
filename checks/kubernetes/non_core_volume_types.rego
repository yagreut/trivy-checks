# METADATA
# title: "Non-core volume types used."
# description: "According to pod security standard 'Volume types', non-core volume types must not be used."
# scope: package
# schemas:
#   - input: schema["kubernetes"]
# related_resources:
#   - https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted
# custom:
#   id: KSV-0028
#   aliases:
#     - AVD-KSV-0028
#     - KSV028
#     - no-non-ephemeral-volumes
#   long_id: kubernetes-no-non-ephemeral-volumes
#   severity: LOW
#   recommended_action: "Do not Set 'spec.volumes[*]' to any of the disallowed volume types."
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
#   examples: checks/kubernetes/non_core_volume_types.yaml
package builtin.kubernetes.KSV028

import rego.v1

import data.lib.kubernetes
import data.lib.utils

# Add disallowed volume type
disallowed_volume_types := [
	"gcePersistentDisk",
	"awsElasticBlockStore",
	# "hostPath", Baseline detects spec.volumes[*].hostPath
	"gitRepo",
	"nfs",
	"iscsi",
	"glusterfs",
	"rbd",
	"flexVolume",
	"cinder",
	"cephFS",
	"flocker",
	"fc",
	"azureFile",
	"vsphereVolume",
	"quobyte",
	"azureDisk",
	"portworxVolume",
	"scaleIO",
	"storageos",
]

# getDisallowedVolumes returns a list of volume names
# which set volume type to any of the disallowed volume types
getDisallowedVolumes contains name if {
	volume := kubernetes.volumes[_]
	type := disallowed_volume_types[_]
	utils.has_key(volume, type)
	name := volume.name
}

# failVolumeTypes is true if any of volume has a disallowed
# volume type
failVolumeTypes if {
	count(getDisallowedVolumes) > 0
}

deny contains res if {
	failVolumeTypes
	msg := kubernetes.format(sprintf("%s '%s' should set 'spec.volumes[*]' to an allowed volume type", [kubernetes.kind, kubernetes.name]))
	res := result.new(msg, input.spec)
}
