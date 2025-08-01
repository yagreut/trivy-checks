# METADATA
# title: Missing description for security group/security group rule.
# description: |
#   Security groups and security group rules should include a description for auditing purposes.
#   Simplifies auditing, debugging, and managing security groups.
# scope: package
# schemas:
#   - input: schema["cloud"]
# related_resources:
#   - https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/SecurityGroups.Creating.html
# custom:
#   id: AWS-0049
#   aliases:
#     - AVD-AWS-0049
#     - add-description-for-security-group
#   long_id: aws-elasticache-add-description-for-security-group
#   provider: aws
#   service: elasticache
#   severity: LOW
#   recommended_action: Add descriptions for all security groups and rules
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: elasticache
#             provider: aws
#   examples: checks/cloud/aws/elasticache/add_description_for_security_group.yaml
package builtin.aws.elasticache.aws0049

import rego.v1

import data.lib.cloud.metadata
import data.lib.cloud.value

deny contains res if {
	some secgroup in input.aws.elasticache.securitygroups
	isManaged(secgroup)
	without_description(secgroup)
	res := result.new(
		"Security group does not have a description.",
		metadata.obj_by_path(secgroup, ["description"]),
	)
}

deny contains res if {
	some secgroup in input.aws.elasticache.securitygroups
	isManaged(secgroup)
	secgroup.description.value == "Managed by Terraform"
	res := result.new(
		"Security group explicitly uses the default description.",
		secgroup.description,
	)
}

without_description(sg) if value.is_empty(sg.description)

without_description(sg) if not sg.description
