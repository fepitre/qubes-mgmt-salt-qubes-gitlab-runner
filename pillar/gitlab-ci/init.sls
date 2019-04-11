gitlab-ci:
  runners:
    - gitlab-ci-01:
        - tag: runner1_tags
        - profile: |
            export TEST1=value1
    - gitlab-ci-02
        - tag: runner1_tags
        - profile: |
            export TEST2=value2
    - gitlab-ci-03
        - tag: runner3_tags
        - profile: |
            export TEST2=value3
# Default NetVMs and templates
  runner-template: fedora-29
  build-template: gitlab-runner-fedora
  build-netvm: sys-firewall
  keys-template: fedora-29-minimal
# Sensitive configuration data
  gitlab_ci_signingkey: 12345678
  gitlab_ci_url: https://gitlab.com/
  gitlab_ci_register_token: 123456789ABCDEF
  github_api_token: 123456789ABCDEF
  github_ssh_key: |
    -----BEGIN RSA PRIVATE KEY-----
    123456789ABCDEF
    -----END RSA PRIVATE KEY-----
