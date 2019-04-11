/etc/yum.repos.d/runner_gitlab-runner.repo:
  file.managed:
    - source: salt://gitlab-ci/runner_gitlab-runner.repo
    - mode: 0644
    - user: root
    - group: root

runner-dependencies:
  pkg.installed:
    - pkgs:
      - gitlab-runner

/etc/systemd/system/gitlab-runner.service:
  file.managed:
    - source: salt://gitlab-ci/gitlab-runner.service
    - mode: 0644
    - user: root
    - group: root

systemd-reload:
  cmd.run:
   - name: systemctl --system daemon-reload