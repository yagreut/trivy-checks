# METADATA
# title: Load balancer is exposed to the internet.
# description: |
#   There are many scenarios in which you would want to expose a load balancer to the wider internet, but this check exists as a warning to prevent accidental exposure of internal assets. You should ensure that this resource should be exposed publicly.
# scope: package
# schemas:
#   - input: schema["cloud"]
# custom:
#   id: AWS-0053
#   aliases:
#     - AVD-AWS-0053
#     - alb-not-public
#   long_id: aws-elb-alb-not-public
#   provider: aws
#   service: elb
#   severity: HIGH
#   recommended_action: Switch to an internal load balancer or add a tfsec ignore
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: elb
#             provider: aws
#   examples: checks/cloud/aws/elb/alb_not_public.yaml
package builtin.aws.elb.aws0053

import rego.v1

import data.lib.cloud.metadata

deny contains res if {
	some lb in input.aws.elb.loadbalancers
	isManaged(lb)
	not is_gateway(lb)
	not lb.internal.value

	res := result.new(
		"Load balancer is exposed publicly.",
		metadata.obj_by_path(lb, ["internal"]),
	)
}

is_gateway(lb) if lb.type.value == "gateway"
