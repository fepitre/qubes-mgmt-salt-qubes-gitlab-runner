{% set any_builderv2 = salt['pillar.get']('gitlab-ci:runners', {}).values() | selectattr('builderv2', 'defined') | list %}

{% if any_builderv2 %}
builder-dvm:
  qvm.vm:
    - present:
      - label: red
    - prefs:
      - template: {{ salt['pillar.get']('gitlab-ci:build-template', 'fedora-36') }}
      - netvm: {{ salt['pillar.get']('gitlab-ci:build-netvm', 'sys-whonix') }}
      - dispvm-allowed: True

volume-builder-dvm:
  cmd.run:
    - name: 'qvm-volume extend builder-dvm:private 30GiB'
{% endif %}

/etc/qubes/policy.d/50-gitlab-ci.policy:
  file.managed:
    - contents: |
{% for runner_name in salt['pillar.get']('gitlab-ci:runners', {}).keys() %}
        qubes.Gpg * {{runner_name}} keys-gitlab-ci allow
{% if salt['pillar.get']('gitlab-ci:runners:' + runner_name + ':builderv2', False) %}
        admin.vm.CreateDisposable * {{runner_name}} dom0 allow
        admin.vm.Start * {{runner_name}} @tag:disp-created-by-{{runner_name}} allow target=dom0
        admin.vm.Kill * {{runner_name}} @tag:disp-created-by-{{runner_name}} allow target=dom0
  
        qubesbuilder.FileCopyIn * {{runner_name}} @tag:disp-created-by-{{runner_name}} allow
        qubesbuilder.FileCopyOut * {{runner_name}} @tag:disp-created-by-{{runner_name}} allow
  
        qubes.WaitForSession * {{runner_name}} @tag:disp-created-by-{{runner_name}} allow
        qubes.VMShell * {{runner_name}} @tag:disp-created-by-{{runner_name}} allow
{% endif %}
{% endfor %}

{% for runner_name in salt['pillar.get']('gitlab-ci:runners', {}).keys() %}
{{runner_name}}:
  qvm.vm:
    - present:
      - label: orange
    - prefs:
      - template: {{ salt['pillar.get']('gitlab-ci:build-template', 'fedora-36') }}
      - netvm: {{ salt['pillar.get']('gitlab-ci:build-netvm', 'sys-firewall') }}
{%- if salt['pillar.get']('gitlab-ci:runners:' + runner_name + ':builderv2', False) %}
      - default-dispvm: builder-dvm
{% endif %}

{{runner_name}}-private-volume:
  cmd.run:
    - name: {{'qvm-volume extend '+runner_name+':private 30GiB'}}
{% endfor %}

keys-gitlab-ci:
  qvm.vm:
    - present:
      - label: black
    - prefs:
      - template: {{ salt['pillar.get']('gitlab-ci:keys-template', 'fedora-36') }}
      - netvm: none
