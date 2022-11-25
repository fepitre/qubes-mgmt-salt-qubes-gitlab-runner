{% set runner_name = grains['id'] %}
{% set runner_tags = salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':tags', []) %}

{% load_yaml as git_config -%}
user.name: fepitre-bot
user.email: fepitre-bot@qubes-os.org
user.signingkey: {{ salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':gitlab_ci_signingkey', '') }}
commit.gpgsign: true
gpg.program: qubes-gpg-client-wrapper
{%- endload %}

#/home/user/.profile:
#  file.managed:
#    - contents_pillar: 'gitlab-ci:runners:{{runner_name}}:profile'
#    - mode: 0644
#    - user: user
#    - group: user

/rw/bind-dirs/var/lib/docker:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/rw/config/qubes-bind-dirs.d/docker.conf:
  file.managed:
    - contents: |
        binds+=('/var/lib/docker')
    - mode: 644
    - user: root
    - group: root
    - makedirs: True
    - dir_mode: 755

/home/user/.rpmmacros:
  file.managed:
    - source: salt://build-infra/rpmmacros
    - mode: 0644
    - user: user
    - group: user

{% for name, value in git_config.items() %}
git-config-{{name}}:
  git.config_set:
    - name: {{name}}
    - value: {{value}}
    - user: user
    - global: True
{% endfor %}

/rw/config/gpg-split-domain:
  file.managed:
    - contents:
      - keys-gitlab-ci
    - mode: 0644
    - user: user

/usr/local/lib/systemd/system/gitlab-runner.service:
  file.managed:
    - source: salt://gitlab-ci/gitlab-runner.service
    - mode: 0644
    - user: root
    - group: root
    - makedirs: True

/usr/local/bin/gitlab-runner:
  file.managed:
    - source: https://s3.amazonaws.com/gitlab-runner-downloads/v15.6.1/binaries/gitlab-runner-linux-amd64
    - source_hash: sha256=5f9b7243f998593aa28fc512d33294b34d710587b68f8f5f31a6449460a85ec2
    - mode: 0775
    - user: root
    - group: root

/rw/config/rc.local:
  file.append:
    - text: |
        usermod -aG mock user
        usermod -aG docker user

        systemctl --system daemon-reload
        systemctl start gitlab-runner

        systemctl start docker

github.com:
  ssh_known_hosts.present:
    - user: user
    - enc: ssh-rsa
    - key: AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
# Disable for now because of Salt bug 37948
    - hash_known_hosts: False

{% if salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':github_ssh_key', '') %}
/home/user/.ssh/id_rsa:
  file.managed:
    - contents_pillar: {{ 'gitlab-ci:runners:'+ runner_name + ':github_ssh_key' }}
    - mode: 600
    - user: user
    - group: user
    - makedirs: True
    - dir_mode: 700
{% endif %}

{% if salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':gitlab_ci_signingkey', '') %}
rpmacros_signingkey:
  file.append:
    - name: /home/user/.rpmmacros
    - text: |
        %_gpg_name {{ salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':gitlab_ci_signingkey', '') }}
{% endif %}

{% if salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':gitlab_ci_register_token', '') %}
gitlab-runner-register:
  cmd.run:
    - runas: user
    - name: echo -e '{{ salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':gitlab_ci_url', 'https://gitlab.com') }}\n{{ salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':gitlab_ci_register_token', '') }}\n{{ runner_name }}\n{{runner_tags|join(',')}}\n\nshell\n' | gitlab-runner register
    - unless:
        - fun: file.file_exists
          path: /home/user/.gitlab-runner/config.toml

runner_output_limit:
  file.prepend:
    - name: /home/user/.gitlab-runner/config.toml
    - text: |
        output_limit = 131072
{% endif %}

{% if salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':openqa_url', '') and salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':openqa_key', '') and salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':openqa_secret', '') %}
/home/user/.config/openqa/client.conf:
  file.managed:
    - mode: 664
    - user: user
    - group: user
    - makedirs: True
    - contents: |
        [{{salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':openqa_url', '')}}]
        key = {{ salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':openqa_key', '') }}
        secret = {{ salt['pillar.get']('gitlab-ci:runners:'+ runner_name + ':openqa_secret', '') }}
{% endif %}
