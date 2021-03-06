{{- define "nova_compute_ironic_conf" }}
{{- $hypervisor := index . 1 }}
{{- with index . 0 }}
[DEFAULT]
host = nova-compute-{{ $hypervisor.name }}
# Needs to be same on hypervisor and scheduler
scheduler_tracks_instance_changes = {{ .Values.scheduler.scheduler_tracks_instance_changes }}
scheduler_instance_sync_interval = {{ .Values.scheduler.scheduler_instance_sync_interval }}
{{- range $k, $v := $hypervisor.default }}
{{ $k }} = {{ $v }}
{{- end }}

[ironic]
{{ $user := print (coalesce .Values.global.ironicServiceUser .Values.global.ironic_service_user "ironic") (default "" .Values.global.user_suffix) }}

{{- if hasPrefix "queens" .Values.imageVersion }}
# keystoneV3 values
auth_type = v3password
auth_url = {{.Values.global.keystone_api_endpoint_protocol_internal | default "http"}}://{{include "keystone_api_endpoint_host_internal" .}}:{{ .Values.global.keystone_api_port_internal | default 5000}}/v3
project_name = {{ default "service" .Values.global.keystone_service_project }}
project_domain_name = {{ default "Default" .Values.global.keystone_service_domain }}
username = {{ $user }}
password = {{ coalesce .Values.global.ironicServicePassword .Values.global.ironic_service_password  (tuple . $user | include "identity.password_for_user")  | replace "$" "$$" }}
user_domain_name = {{ default "Default" .Values.global.keystone_service_domain }}
# api endpoint is found via keystone catalog
{{- else }}
admin_url = {{.Values.global.keystone_api_endpoint_protocol_internal | default "http"}}://{{include "keystone_api_endpoint_host_internal" .}}:{{ .Values.global.keystone_api_port_internal | default 5000}}/v3
admin_username = {{ $user }}
admin_user_domain_name = {{ default "Default" .Values.global.keystone_service_domain }}
admin_password = {{ coalesce .Values.global.ironicServicePassword .Values.global.ironic_service_password  (tuple . $user | include "identity.password_for_user")  | replace "$" "$$" }}
admin_tenant_name = {{ default "service" .Values.global.keystone_service_project }}
admin_project_domain_name = {{ default "Default" .Values.global.keystone_service_domain }}
api_endpoint = {{ default "http" .Values.global.ironic_api_endpoint_protocol_admin }}://{{ include "ironic_api_endpoint_host_internal" .}}:{{ .Values.global.ironic_api_port_internal | default "6385" }}/v1
{{- end }}

{{- range $k, $v := $hypervisor.ironic }}
{{ $k }} = {{ $v }}
{{- end }}


{{- end }}
{{- end }}
