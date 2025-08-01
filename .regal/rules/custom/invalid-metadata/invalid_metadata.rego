# METADATA
# description: |
#   Ensures that metadata definitions adhere to the required schema by validating the following:
#   - Ensure all necessary fields are present in metadata.
#   - Detect and report any unexpected or forbidden fields.
#   - Validate that field values are compliant with the expected format or constraints.
# schemas:
# - input: schema.regal.ast
package custom.regal.rules.custom["invalid-metadata"]

import rego.v1

import data.regal.ast
import data.regal.result

report contains _violation_check(lib_metadata_schema) if _is_lib_package

report contains _violation_check(check_metadata_schema) if not _is_lib_package

report contains violation if {
	some annot in _pkg_annotations
	message := _validate_id(annot.custom.id)
	violation := _build_violation(annot, [message])
}

report contains violation if {
	some annot in _pkg_annotations
	message := _validate_long_id(annot.custom)
	violation := _build_violation(annot, [message])
}

report contains violation if {
	some annot in _pkg_annotations
	message := _validate_trivy_version(annot.custom.minimum_trivy_version)
	violation := _build_violation(annot, [message])
}

_is_lib_package if input["package"].path[1].value == "lib"

_pkg_annotations := [annot | some annot in input["package"].annotations; annot.scope == "package"]

_id_pattern := `^(AWS|GCP|DIG|AZU|KCV|KSV|DS|GIT|NIF|KUBE|OPNSTK|CLDSTK|OCI)-\d+$`

_validate_id(id) := sprintf("id (%s): Does not match pattern '%s'", [id, _id_pattern]) if {
	not regex.match(_id_pattern, id)
}

_validate_long_id(custom_meta) := msg if {
	prefix := sprintf("%s-%s-", [custom_meta.provider, replace(custom_meta.service, "-", "")])
	not startswith(custom_meta.long_id, prefix)
	msg := sprintf(
		"long_id (%s): must start with  <provider>-<service>-...",
		[custom_meta.long_id],
	)
}

_validate_trivy_version(ver) := msg if {
	not semver.is_valid(ver)
	msg := sprintf("minimum_trivy_version (%s) must be a valid SemVer string", [ver])
}

_build_violation(annot, errors) := result.fail(
	rego.metadata.chain(),
	object.union(
		result.location(annot),
		{"description": concat("\n", errors)},
	),
)

_violation_check(schema) := _build_violation(annot, error_messages) if {
	some annot in _pkg_annotations
	[match, errors] := json.match_schema(annot.custom, schema)
	not match
	error_messages := [err.error | some err in errors]
}

lib_metadata_schema := {
	"$schema": "http://json-schema.org/draft-07/schema#",
	"type": "object",
	"properties": {
		"library": {"type": "boolean"},
		"input": input_schema,
	},
	"required": ["library"],
	"additionalProperties": false,
}

check_metadata_schema := {
	"$schema": "http://json-schema.org/draft-07/schema#",
	"type": "object",
	"properties": {
		"id": {"type": "string"},
		"provider": {"type": "string"},
		"service": {"type": "string"},
		"short_code": {"type": "string"},
		"long_id": {"type": "string"},
		"severity": {
			"type": "string",
			"enum": ["LOW", "MEDIUM", "HIGH", "CRITICAL"],
		},
		"input": input_schema,
		"frameworks": {"type": "object"},
		"deprecated": {"type": "boolean"},
		"examples": {"type": "string"},
		"aliases": {
			"type": "array",
			"items": {"type": "string"},
		},
		"cloud_formation": {"$ref": "#/$defs/engine_metadata"},
		"terraform": {"$ref": "#/$defs/engine_metadata"},
		"recommended_actions": {"type": "string"},
		"recommended_action": {"type": "string"},
		"minimum_trivy_version": {"type": "string"},
	},
	"required": ["id", "input"],
	"additionalProperties": false,
	"anyOf": [
		{"required": ["recommended_actions"]},
		{"required": ["recommended_action"]},
		{"not": {"required": ["recommended_actions", "recommended_action"]}},
	],
	"$defs": {"engine_metadata": {
		"type": "object",
		"properties": {
			"good_examples": {"type": "string"},
			"bad_examples": {"type": "string"},
			"links": {
				"type": "array",
				"items": {
					"type": "string",
					"format": "uri",
				},
			},
		},
		"additionalProperties": false,
	}},
}

input_schema := {
	"type": "object",
	"properties": {"selector": {
		"type": "array",
		"items": {
			"type": "object",
			"properties": {
				"type": {"type": "string"},
				"subtypes": {
					"type": "array",
					"items": {
						"type": "object",
						"oneOf": [
							{
								"properties": {"kind": {"type": "string"}},
								"required": ["kind"],
								"additionalProperties": false,
							},
							{
								"properties": {
									"provider": {"type": "string"},
									"service": {"type": "string"},
								},
								"required": ["service", "provider"],
								"additionalProperties": false,
							},
						],
					},
				},
			},
			"required": ["type"],
			"additionalProperties": false,
		},
	}},
	"additionalProperties": false,
}
