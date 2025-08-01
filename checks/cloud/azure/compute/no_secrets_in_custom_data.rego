# METADATA
# title: Ensure that no sensitive credentials are exposed in VM custom_data
# description: |
#   When creating Azure Virtual Machines, custom_data is used to pass start up information into the EC2 instance. This custom_dat must not contain access key credentials.
# scope: package
# schemas:
#   - input: schema["cloud"]
# custom:
#   id: AZU-0037
#   aliases:
#     - AVD-AZU-0037
#     - no-secrets-in-custom-data
#   long_id: azure-compute-no-secrets-in-custom-data
#   provider: azure
#   service: compute
#   severity: MEDIUM
#   recommended_action: Don't use sensitive credentials in the VM custom_data
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: compute
#             provider: azure
#   examples: checks/cloud/azure/compute/no_secrets_in_custom_data.yaml
package builtin.azure.compute.azure0037

import rego.v1

deny contains res if {
	vms := array.concat(
		object.get(input.azure.compute, "linuxvirtualmachines", []),
		object.get(input.azure.compute, "windowsvirtualmachines", []),
	)

	some vm in vms
	scan_result := squealer.scan_string(vm.virtualmachine.customdata.value)
	scan_result.transgressionFound
	res := result.new(
		"Virtual machine includes secret(s) in custom data.",
		vm.virtualmachine,
	)
}
