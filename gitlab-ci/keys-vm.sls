# Create stat file for each runner
{%- for runner in salt['pillar.get']('gitlab-ci:runners', []) %}
/rw/config/rc.local:
  file.append:
    - text: touch /var/run/qubes-gpg-split/stat.build-{{runner}}
    - context:
      - mode: 0755
{%- endfor %}

# WIP: QUBES_GPG_AUTOACCEPT = 365 days
# currently we have not hook for triggering stat file like in qubes-infrastructure
/home/user/.profile:
  file.prepend:
    - text:
        - export QUBES_GPG_AUTOACCEPT=31536000
