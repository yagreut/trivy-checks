# METADATA
# title: An Network ACL rule allows ALL ports.
# description: |
#   Ensure access to specific required ports is allowed, and nothing else.
# scope: package
# schemas:
#   - input: schema["cloud"]
# related_resources:
#   - https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html
# custom:
#   id: AWS-0102
#   aliases:
#     - AVD-AWS-0102
#     - aws-vpc-no-excessive-port-access
#     - no-excessive-port-access
#   long_id: aws-ec2-no-excessive-port-access
#   provider: aws
#   service: ec2
#   severity: CRITICAL
#   recommended_action: Set specific allowed ports
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: ec2
#             provider: aws
#   examples: checks/cloud/aws/ec2/no_excessive_port_access.yaml
package builtin.aws.ec2.aws0102

import rego.v1

all_protocols := {"all", "-1"}

deny contains res if {
	some rule in input.aws.ec2.networkacls[_].rules
	rule.action.value == "allow"
	rule.protocol.value in all_protocols
	res := result.new("Network ACL rule allows access using ALL ports.", rule.protocol)
}
