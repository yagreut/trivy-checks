# METADATA
# title: IAM Password policy should prevent password reuse.
# description: |
#   IAM account password policies should prevent the reuse of passwords.
#
#   The account password policy should be set to prevent using any of the last five used passwords.
# scope: package
# schemas:
#   - input: schema["cloud"]
# related_resources:
#   - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_passwords_account-policy.html#password-policy-details
# custom:
#   id: AWS-0056
#   aliases:
#     - AVD-AWS-0056
#     - no-password-reuse
#   long_id: aws-iam-no-password-reuse
#   provider: aws
#   service: iam
#   severity: MEDIUM
#   recommended_action: Prevent password reuse in the policy
#   frameworks:
#     default:
#       - null
#     cis-aws-1.2:
#       - "1.10"
#     cis-aws-1.4:
#       - "1.9"
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: iam
#             provider: aws
#   examples: checks/cloud/aws/iam/no_password_reuse.yaml
package builtin.aws.iam.aws0056

import rego.v1

import data.lib.cloud.value

deny contains res if {
	policy := input.aws.iam.passwordpolicy
	isManaged(policy)
	value.less_than(policy.reusepreventioncount, 5)
	res := result.new("Password policy allows reuse of recent passwords.", policy)
}
