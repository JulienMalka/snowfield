# Taken from 'config.template.yml' for Authelia v4.32.2.
# Update along with 'pkgs/authelia.nix'.

{ cfg }:
''
server:
  host: 0.0.0.0
  port: 9091
  read_buffer_size: 4096
  write_buffer_size: 4096
  path: "authelia"
log.level: debug
jwt_secret: somethingsomethingrandomrecret
default_redirection_url: https://autheliafailed.julienmalka.me
authentication_backend:
  disable_reset_password: false
  file:
    path: ${./config/users.yml}
    password:
      algorithm: argon2id
      iterations: 1
      key_length: 32
      salt_length: 16
      memory: 512
      parallelism: 8
      
access_control:
  default_policy: deny
  rules:
    - domain:
        - "auth.julienmalka.me"
      policy: bypass
    - domain:
        - "series.julienmalka.me"
      policy: one_factor
 
session:
  name: authelia_session
  secret: somerandomsecret
  expiration: 1h
  inactivity: 5m
  remember_me_duration: 1M
  domain: julienmalka.me
regulation:
  max_retries: 3
  find_time: 2m
  ban_time: 5m
storage:
  encryption_key: a_very_important_secret
  local:
    path: /var/lib/authelia/storage.db
notifier:
  disable_startup_check: false
  filesystem:
    filename: /var/lib/authelia/notification.txt
''

