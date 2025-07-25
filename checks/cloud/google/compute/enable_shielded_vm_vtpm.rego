# METADATA
# title: Instances should have Shielded VM VTPM enabled
# description: |
#   The virtual TPM provides numerous security measures to your VM.
# scope: package
# schemas:
#   - input: schema["cloud"]
# related_resources:
#   - https://cloud.google.com/blog/products/identity-security/virtual-trusted-platform-module-for-shielded-vms-security-in-plaintext
# custom:
#   id: GCP-0041
#   aliases:
#     - AVD-GCP-0041
#     - enable-shielded-vm-vtpm
#   long_id: google-compute-enable-shielded-vm-vtpm
#   provider: google
#   service: compute
#   severity: MEDIUM
#   recommended_action: Enable Shielded VM VTPM
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: compute
#             provider: google
#   examples: checks/cloud/google/compute/enable_shielded_vm_vtpm.yaml
package builtin.google.compute.google0041

import rego.v1

deny contains res if {
	some instance in input.google.compute.instances
	instance.shieldedvm.vtpmenabled.value == false
	res := result.new(
		"Instance does not have VTPM for shielded VMs enabled.",
		instance.shieldedvm.vtpmenabled,
	)
}
