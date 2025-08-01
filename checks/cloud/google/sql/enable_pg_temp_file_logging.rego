# METADATA
# title: Temporary file logging should be enabled for all temporary files.
# description: |
#   Temporary files are not logged by default. To log all temporary files, a value of `0` should set in the `log_temp_files` flag - as all files greater in size than the number of bytes set in this flag will be logged.
# scope: package
# schemas:
#   - input: schema["cloud"]
# related_resources:
#   - https://postgresqlco.nf/doc/en/param/log_temp_files/
# custom:
#   id: GCP-0014
#   aliases:
#     - AVD-GCP-0014
#     - enable-pg-temp-file-logging
#   long_id: google-sql-enable-pg-temp-file-logging
#   provider: google
#   service: sql
#   severity: MEDIUM
#   recommended_action: Enable temporary file logging for all files
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: sql
#             provider: google
#   examples: checks/cloud/google/sql/enable_pg_temp_file_logging.yaml
package builtin.google.sql.google0014

import rego.v1

import data.lib.cloud.value
import data.lib.google.database

deny contains res if {
	some instance in input.google.sql.instances
	database.is_postgres(instance)
	msg := check_log_temp_file_size(instance.settings.flags.logtempfilesize)
	msg != ""
	res := result.new(msg, instance.settings.flags.logtempfilesize)
}

check_log_temp_file_size(logtempfilesize) := msg if {
	value.less_than(logtempfilesize, 0)
	msg := "Database instance has temporary file logging disabled."
}

check_log_temp_file_size(logtempfilesize) := msg if {
	value.greater_than(logtempfilesize, 0)
	msg := "Database instance has temporary file logging disabled for files of certain sizes."
}
