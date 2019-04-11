{% set runner_name = grains['id']|replace('build-','') %}
{% set runner_tags = salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':tags', '') %}

{% load_yaml as git_config -%}
user.name: fepitre-bot
user.email: fepitre-bot@qubes-os.org
user.signingkey: {{ pillar['gitlab-ci']['gitlab_ci_signingkey'] }}
commit.gpgsign: true
gpg.program: qubes-gpg-client-wrapper
{%- endload %}

/home/user/.profile:
  file.managed:
    - contents_pillar: 'gitlab-ci:runners:{{runner_name}}:profile'
    - mode: 0644
    - user: user
    - group: user

/home/user/.rpmmacros:
  file.managed:
    - source: salt://build-infra/rpmmacros
    - mode: 0644
    - user: user
    - group: user

rpmacros_signingkey:
  file.append:
    - name: /home/user/.rpmmacros
    - text: %_gpg_name {{ pillar['gitlab-ci']['gitlab_ci_signingkey'] }}

{% for name, value in git_config.items() %}
git-config-{{name}}:
  git.config_set:
    - name: {{name}}
    - value: {{value}}
    - user: user
    - global: True
{% endfor %}

/home/user/.github_api_token:
  file.managed:
    - contents_pillar: gitlab-ci:github_api_token
    - mode: 600
    - user: user
    - group: user

/home/user/.ssh/id_rsa:
  file.managed:
    - contents_pillar: gitlab-ci:github_ssh_key
    - mode: 600
    - user: user
    - group: user
    - makedirs: True
    - dir_mode: 700

/rw/config/gpg-split-domain:
  file.managed:
    - contents:
      - keys-gitlab-ci
    - mode: 0644
    - user: user

github.com:
  ssh_known_hosts.present:
    - user: user
    - enc: ssh-rsa
    - key: AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
# Disable for now because of Salt bug 37948
    - hash_known_hosts: False

gitlab-runner-register:
  cmd.run:
    - runas: user
    - name: echo -e '{{ pillar['gitlab-ci']['gitlab_ci_url'] }}\n{{ pillar['gitlab-ci']['gitlab_ci_register_token'] }}\n{{ runner_name }}\n{{ runner_tags }}\nshell\n' | gitlab-runner register
    - unless: file.exists /home/user/.gitlab-runner/config.toml
