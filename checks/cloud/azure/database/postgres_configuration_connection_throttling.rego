# METADATA
# title: Ensure server parameter 'connection_throttling' is set to 'ON' for PostgreSQL Database Server
# description: |
#   Postgresql can generate logs for connection throttling to improve visibility for audit and configuration issue resolution.
# scope: package
# schemas:
#   - input: schema["cloud"]
# related_resources:
#   - https://docs.microsoft.com/en-us/azure/postgresql/concepts-server-logs#configure-logging
# custom:
#   id: AZU-0021
#   aliases:
#     - AVD-AZU-0021
#     - postgres-configuration-connection-throttling
#   long_id: azure-database-postgres-configuration-connection-throttling
#   provider: azure
#   service: database
#   severity: MEDIUM
#   recommended_action: Enable connection throttling logging
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: database
#             provider: azure
#   examples: checks/cloud/azure/database/postgres_configuration_connection_throttling.yaml
package builtin.azure.database.azure0021

import rego.v1

import data.lib.cloud.metadata

deny contains res if {
	some server in input.azure.database.postgresqlservers
	isManaged(server)

	not server.config.connectionthrottling.value
	res := result.new(
		"Database server is not configured to throttle connections.",
		metadata.obj_by_path(server, ["config", "connectionthrottling"]),
	)
}
