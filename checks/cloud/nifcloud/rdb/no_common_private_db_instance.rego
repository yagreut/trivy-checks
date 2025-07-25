# METADATA
# title: The db instance has common private network
# description: |
#   When handling sensitive data between servers, please consider using a private LAN to isolate the private side network from the shared network.
# scope: package
# schemas:
#   - input: schema["cloud"]
# related_resources:
#   - https://pfs.nifcloud.com/service/plan.htm
# custom:
#   id: NIF-0010
#   aliases:
#     - AVD-NIF-0010
#     - nifcloud-rdb-no-common-private-db-instance
#     - no-common-private-db-instance
#   long_id: nifcloud-rdb-no-common-private-db-instance
#   provider: nifcloud
#   service: rdb
#   severity: LOW
#   recommended_action: Use private LAN
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: rdb
#             provider: nifcloud
#   examples: checks/cloud/nifcloud/rdb/no_common_private_db_instance.yaml
package builtin.nifcloud.rdb.nifcloud0010

import rego.v1

deny contains res if {
	some db in input.nifcloud.rdb.dbinstances
	db.networkid.value == "net-COMMON_PRIVATE"
	res := result.new("The db instance has common private network.", db.networkid)
}
