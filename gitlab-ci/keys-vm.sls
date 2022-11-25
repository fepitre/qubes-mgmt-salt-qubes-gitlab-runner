# Create stat file for each runner
{%- for runner in salt['pillar.get']('gitlab-ci:runners', {}).keys() %}
{{runner}}_split_gpg_stat:
  file.append:
    - name: /rw/config/rc.local
    - text: |
        mkdir /run/qubes-gpg-split
        touch /run/qubes-gpg-split/stat.{{runner}}
    - context:
      - mode: 0755
{%- endfor %}

# WIP: QUBES_GPG_AUTOACCEPT = 365 days
# currently we have no hook for triggering stat file like in qubes-infrastructure
/home/user/.profile:
  file.prepend:
    - text:
        - export QUBES_GPG_AUTOACCEPT=31536000
