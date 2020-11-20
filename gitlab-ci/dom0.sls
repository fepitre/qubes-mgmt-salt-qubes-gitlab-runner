# Install Fedora minimal template
qubes-template-{{ salt['pillar.get']('gitlab-ci:keys-template', 'fedora-32-minimal') }}:
  pkg.installed

# Create Gitlab Runner template from Fedora template
gitlab-ci-template:
  qvm.clone:
      - name: {{ salt['pillar.get']('gitlab-ci:build-template', 'gitlab-runner-fedora') }}
      - source: {{ salt['pillar.get']('gitlab-ci:runner-template', 'fedora-29') }}

/etc/qubes-rpc/policy/qubes.Gpg:
  file.prepend:
    - text:
{%- for runner in salt['pillar.get']('gitlab-ci:runners', []) %}
      - build-{{runner}} keys-gitlab-ci allow
      - $anyvm keys-gitlab-ci deny
{% endfor %}

{%- for runner in salt['pillar.get']('gitlab-ci:runners', []) %}
build-{{runner}}:
  qvm.vm:
    - present:
      - label: green
    - prefs:
      - template: {{ salt['pillar.get']('gitlab-ci:build-template', 'gitlab-runner-fedora') }}
      - netvm: {{ salt['pillar.get']('gitlab-ci:build-netvm', 'sys-firewall') }}
{%- endfor %}

keys-gitlab-ci:
  qvm.vm:
    - present:
      - label: black
    - prefs:
      - template: {{ salt['pillar.get']('gitlab-ci:keys-template', 'fedora-29-minimal') }}
      - netvm: none
