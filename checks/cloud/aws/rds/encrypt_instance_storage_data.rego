# METADATA
# title: RDS encryption has not been enabled at a DB Instance level.
# description: |
#   Encryption should be enabled for an RDS Database instances.
#   When enabling encryption by setting the kms_key_id.
# scope: package
# schemas:
#   - input: schema["cloud"]
# related_resources:
#   - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html
# custom:
#   id: AWS-0080
#   aliases:
#     - AVD-AWS-0080
#     - encrypt-instance-storage-data
#   long_id: aws-rds-encrypt-instance-storage-data
#   provider: aws
#   service: rds
#   severity: HIGH
#   recommended_action: Enable encryption for RDS instances
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: rds
#             provider: aws
#   examples: checks/cloud/aws/rds/encrypt_instance_storage_data.yaml
package builtin.aws.rds.aws0080

import rego.v1

import data.lib.cloud.metadata
import data.lib.cloud.value

deny contains res if {
	some instance in input.aws.rds.instances
	without_replication_source_arn(instance)
	encryption_disabled(instance)
	res := result.new(
		"Instance does not have storage encryption enabled.",
		metadata.obj_by_path(instance, ["encryption", "encryptstorage"]),
	)
}

without_replication_source_arn(instance) if value.is_empty(instance.replicationsourcearn)

without_replication_source_arn(instance) if not instance.replicationsourcearn

encryption_disabled(instance) if value.is_false(instance.encryption.encryptstorage)

encryption_disabled(instance) if not instance.encryption.encryptstorage
