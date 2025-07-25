# METADATA
# title: IAM Password policy should have minimum password length of 14 or more characters.
# description: |
#   IAM account password policies should ensure that passwords have a minimum length.
#
#   The account password policy should be set to enforce minimum password length of at least 14 characters.
# scope: package
# schemas:
#   - input: schema["cloud"]
# related_resources:
#   - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_passwords_account-policy.html#password-policy-details
# custom:
#   id: AWS-0063
#   aliases:
#     - AVD-AWS-0063
#     - set-minimum-password-length
#   long_id: aws-iam-set-minimum-password-length
#   provider: aws
#   service: iam
#   severity: MEDIUM
#   recommended_action: Enforce longer, more complex passwords in the policy
#   frameworks:
#     default:
#       - null
#     cis-aws-1.2:
#       - "1.9"
#     cis-aws-1.4:
#       - "1.8"
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: iam
#             provider: aws
#   examples: checks/cloud/aws/iam/set_minimum_password_length.yaml
package builtin.aws.iam.aws0063

import rego.v1

import data.lib.cloud.value

msg := "Password policy allows a maximum password age of greater than 90 days"

deny contains res if {
	policy := input.aws.iam.passwordpolicy
	isManaged(policy)
	value.less_than(policy.minimumlength, 14)
	res := result.new(
		"Password policy allows a maximum password age of greater than 90 days",
		policy.minimumlength,
	)
}
