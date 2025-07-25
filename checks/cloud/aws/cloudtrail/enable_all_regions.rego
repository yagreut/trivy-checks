# METADATA
# title: Cloudtrail should be enabled in all regions regardless of where your AWS resources are generally homed
# description: |
#   Activity could be happening in your account in a different region. When creating Cloudtrail in the AWS Management Console the trail is configured by default to be multi-region, this isn't the case with the Terraform resource. Cloudtrail should cover the full AWS account to ensure you can track changes in regions you are not actively operating in.
# scope: package
# schemas:
#   - input: schema["cloud"]
# related_resources:
#   - https://docs.aws.amazon.com/awscloudtrail/latest/userguide/receive-cloudtrail-log-files-from-multiple-regions.html
# custom:
#   id: AWS-0014
#   aliases:
#     - AVD-AWS-0014
#     - enable-all-regions
#   long_id: aws-cloudtrail-enable-all-regions
#   provider: aws
#   service: cloudtrail
#   severity: MEDIUM
#   recommended_action: Enable Cloudtrail in all regions
#   frameworks:
#     default:
#       - null
#     cis-aws-1.2:
#       - "2.5"
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: cloudtrail
#             provider: aws
#   examples: checks/cloud/aws/cloudtrail/enable_all_regions.yaml
package builtin.aws.cloudtrail.aws0014

import rego.v1

import data.lib.cloud.metadata

deny contains res if {
	some trail in input.aws.cloudtrail.trails
	not trail.ismultiregion.value
	res := result.new(
		"Trail is not enabled across all regions.",
		metadata.obj_by_path(trail, ["ismultiregion"]),
	)
}
