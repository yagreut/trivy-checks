# METADATA
# title: Ensure AKS logging to Azure Monitoring is Configured
# description: |
#   Ensure AKS logging to Azure Monitoring is configured for containers to monitor the performance of workloads.
# scope: package
# schemas:
#   - input: schema["cloud"]
# related_resources:
#   - https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-onboard
# custom:
#   id: AZU-0040
#   aliases:
#     - AVD-AZU-0040
#     - logging
#   long_id: azure-container-logging
#   provider: azure
#   service: container
#   severity: MEDIUM
#   recommended_action: Enable logging for AKS
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: container
#             provider: azure
#   examples: checks/cloud/azure/container/logging.yaml
package builtin.azure.container.azure0040

import rego.v1

import data.lib.cloud.metadata

deny contains res if {
	some cluster in input.azure.container.kubernetesclusters
	isManaged(cluster)
	not cluster.addonprofile.omsagent.enabled.value
	res := result.new(
		"Cluster does not have logging enabled via OMS Agent.",
		metadata.obj_by_path(cluster, ["addonprofile", "omsagent", "enabled"]),
	)
}
