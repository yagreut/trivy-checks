# METADATA
# title: "ConfigMap with sensitive content"
# description: "Storing sensitive content such as usernames and email addresses in configMaps is unsafe"
# scope: package
# schemas:
#   - input: schema["kubernetes"]
# custom:
#   id: KSV-01010
#   aliases:
#     - AVD-KSV-01010
#     - configMap_with_sensitive
#   long_id: kubernetes-configMap-with-sensitive
#   severity: MEDIUM
#   recommended_action: "Remove sensitive content from configMap data value"
#   input:
#     selector:
#       - type: kubernetes
#         subtypes:
#           - kind: configmap
package builtin.kubernetes.KSV01010

import rego.v1

import data.lib.kubernetes

# More patterns can be added here, adding more patterns may lead to performance issue
# some patterns are taken from https://github.com/americanexpress/earlybird/blob/d0b63538c1acbb5ab0cacf0541df5ea088d45d70/config/content.json
patterns := [
	"(?i)(username\\s*(=|:))",
	"(?i)(email\\s*(=|:))",
	"([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)",
	"(?i)(key\\s*(=|:))",
	"(?i)(phone\\s*(=|:))",
	"[^\\.](?:\\b[A-Z]{2}\\d{2} ?\\d{4} ?\\d{4} ?\\d{4} ?\\d{4} ?[\\d]{0,2}\\b)",
	"(?i)(SHA1)",
	"(?i)(MD5)",
	"(?i)(iban\\s*(=|:))",
]

patternsForKey := [
	"(?i)(username\\s*)",
	"(?i)(email\\s*)",
	"([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)",
	"(?i)(key\\s*)",
	"(?i)(phone\\s*)",
	"[^\\.](?:\\b[A-Z]{2}\\d{2} ?\\d{4} ?\\d{4} ?\\d{4} ?\\d{4} ?[\\d]{0,2}\\b)",
	"(?i)(SHA1\\s*)",
	"(?i)(MD5\\s*)",
	"(?i)(iban\\s*)",
]

patternsForEmail := "([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)"

# - https://www.iban.com/structure
patternForIbanAndPassport := [
	"([A-Z]{2}[ \\-]?[0-9]{2}[ \\-]?([A-Z0-9]{3,5}[ \\-]?){2,7}[A-Z0-9]{1,3})",
	"^[A-Z0-9<]{3,20}$",
]

# ConfigMapWithSensitive gives secret key
# To reduce performance overhead, only matched patterns will be applied to each value for key
ConfigMapWithSensitive contains sensitiveData if {
	kubernetes.kind == "ConfigMap"
	regex.match(patterns[p], kubernetes.object.data[d])

	values := split(kubernetes.object.data[d], "\n")
	regex.match(patterns[p], values[v])
	sensitiveData = configMapValue(values[v])
}

# configMapValue gives sensitive key, splitting either by '=' or ':'
configMapValue(value) := sensitiveValue if {
	sensitiveData := split(value, ":")
	count(sensitiveData) > 1
	sensitiveValue = sensitiveData[0]
} else := sensitiveValue if {
	sensitiveData := split(value, "=")
	count(sensitiveData) > 1
	sensitiveValue = sensitiveData[0]
}

#check if key has sensitive data
ConfigMapWithSensitive contains sensitiveData if {
	kubernetes.kind == "ConfigMap"
	values = split(kubernetes.object.data[d], "\n")
	regex.match(patternsForKey[p], d)
	sensitiveData = d
}

ConfigMapWithSensitive contains sensitiveData if {
	kubernetes.kind == "ConfigMap"
	values = split(kubernetes.object.data[d], "\n")
	val = split(values[v], ":")
	regex.match(patternsForEmail, val[v])
	sensitiveData = d
}

ConfigMapWithSensitive contains sensitiveData if {
	input.kind == "ConfigMap"
	values = split(kubernetes.object.data[d], "\n")
	val = split(values[v], ":")
	regex.match(patternForIbanAndPassport[p], val[v])
	sensitiveData = d
}

configMapSensitiveList := ConfigMapWithSensitive

deny contains res if {
	count(configMapSensitiveList) > 0
	msg := kubernetes.format(sprintf("%s '%s' in '%s' namespace stores sensitive contents in key(s) or value(s) '%s'", [kubernetes.kind, kubernetes.name, kubernetes.namespace, configMapSensitiveList]))
	res := result.new(msg, kubernetes.kind)
}
