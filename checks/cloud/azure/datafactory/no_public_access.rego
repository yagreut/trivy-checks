# METADATA
# title: Data Factory should have public access disabled, the default is enabled.
# description: |
#   Data Factory has public access set to true by default.
#
#   Disabling public network access is applicable only to the self-hosted integration runtime, not to Azure Integration Runtime and SQL Server Integration Services (SSIS) Integration Runtime.
# scope: package
# schemas:
#   - input: schema["cloud"]
# related_resources:
#   - https://docs.microsoft.com/en-us/azure/data-factory/data-movement-security-considerations#hybrid-scenarios
# custom:
#   id: AZU-0035
#   aliases:
#     - AVD-AZU-0035
#     - no-public-access
#   long_id: azure-datafactory-no-public-access
#   provider: azure
#   service: datafactory
#   severity: CRITICAL
#   recommended_action: Set public access to disabled for Data Factory
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: datafactory
#             provider: azure
#   examples: checks/cloud/azure/datafactory/no_public_access.yaml
package builtin.azure.datafactory.azure0035

import rego.v1

deny contains res if {
	some factory in input.azure.datafactory.datafactories
	factory.enablepublicnetwork.value == true
	res := result.new(
		"Data factory allows public network access.",
		factory.enablepublicnetwork,
	)
}
