# METADATA
# title: Security threat alerts go to subscription owners and co-administrators
# description: |
#   Subscription owners should be notified when there are security alerts. By ensuring the administrators of the account have been notified they can quickly assist in any required remediation
# scope: package
# schemas:
#   - input: schema["cloud"]
# custom:
#   id: AZU-0023
#   aliases:
#     - AVD-AZU-0023
#     - threat-alert-email-to-owner
#   long_id: azure-database-threat-alert-email-to-owner
#   provider: azure
#   service: database
#   severity: LOW
#   recommended_action: Enable email to subscription owners
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: database
#             provider: azure
#   examples: checks/cloud/azure/database/threat_alert_email_to_owner.yaml
package builtin.azure.database.azure0023

import rego.v1

deny contains res if {
	some server in input.azure.database.mssqlservers
	some policy in server.securityalertpolicies
	not policy.emailaccountadmins.value
	res := result.new(
		"Security alert policy does not alert account admins.",
		object.get(policy, "emailaccountadmins", policy),
	)
}
