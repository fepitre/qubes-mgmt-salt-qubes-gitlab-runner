gitlab-ci:
  runners:
    gitlab-ci-01:
      tags:
        - runner1_tags
      profile: |
        export TEST1=value1
      # GitLab
      gitlab_ci_signingkey: 123456789ABCDEF
      gitlab_ci_url: https://gitlab.com/
      gitlab_ci_register_token: 123456789ABCDEF
      # GitHub
      github_ssh_key: |
        -----BEGIN RSA PRIVATE KEY-----
        123456789ABCDEF
        -----END RSA PRIVATE KEY-----
      # openQA
      openqa_url: openqa.qubes-os.org
      openqa_key: 123456789ABCDEF
      openqa_secret: 123456789ABCDEF
    gitlab-ci-02:
      builderv2: True
      tags:
        - runner2_tags
      profile: |
        export TEST2=value2
      # GitLab
      gitlab_ci_signingkey: 123456789ABCDEF
      gitlab_ci_url: https://gitlab.com/
      gitlab_ci_register_token: 123456789ABCDEF
    gitlab-ci-03:
      tags:
        - runner3_tags
      profile: |
        export TEST3=value3
      # GitLab
      gitlab_ci_signingkey: 123456789ABCDEF
      gitlab_ci_url: https://gitlab.com/
      gitlab_ci_register_token: 123456789ABCDEF
  # Default NetVMs and templates
  build-template: fedora-36
  build-netvm: sys-firewall
  keys-template: fedora-36
