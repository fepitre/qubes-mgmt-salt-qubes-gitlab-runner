gitlab-ci:
  orchestrator: gitlab-ci-orchestrator
# Default NetVMs and templates
  runner-template: fedora-30
  orchestrator-template: centos-8
  build-template: gitlab-runner-fedora
  build-netvm: sys-firewall
# Sensitive configuration data
  gitlab_ci_signingkey: 12345678
  gitlab_ci_url: https://gitlab.com/
  gitlab_ci_register_token: 123456789ABCDEF
  github_api_token: 123456789ABCDEF
  github_ssh_key: |
    -----BEGIN RSA PRIVATE KEY-----
    123456789ABCDEF
    -----END RSA PRIVATE KEY-----
