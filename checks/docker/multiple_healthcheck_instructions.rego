# METADATA
# title: "Multiple HEALTHCHECK defined"
# description: "Providing more than one HEALTHCHECK instruction per stage is confusing and error-prone."
# scope: package
# schemas:
#   - input: schema["dockerfile"]
# related_resources:
#   - https://docs.docker.com/engine/reference/builder/#healthcheck
# custom:
#   id: DS-0023
#   aliases:
#     - AVD-DS-0023
#     - DS023
#     - only-one-healthcheck
#   long_id: docker-only-one-healthcheck
#   severity: MEDIUM
#   recommended_action: "One HEALTHCHECK instruction must remain in Dockerfile. Remove all other instructions."
#   input:
#     selector:
#       - type: dockerfile
#   examples: checks/docker/multiple_healthcheck_instructions.yaml
package builtin.dockerfile.DS023

import rego.v1

import data.lib.docker

deny contains res if {
	healthchecks := docker.stage_healthcheck[name]
	cnt := count(healthchecks)
	cnt > 1
	msg := sprintf("There are %d duplicate HEALTHCHECK instructions in the stage", [cnt])
	res := result.new(msg, healthchecks[1])
}
