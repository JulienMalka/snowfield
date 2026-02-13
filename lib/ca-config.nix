{
  stepCAUrl = "https://ca.luj";
  caFingerprint = "5410913018dbea32be7f6183bed593530d1d4448253df75d5af3cd4e724b6395"; # from: step certificate fingerprint /etc/smallstep/certs/root_ca.crt
  sshUserCAPublicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBF6MNHywQZpTpWNfgExROZexi4nBBQ8cOn+Mq1s5iiph4WZHnzKRthOsYiCpV+GD+JYg4jk0BQr12HsEfwM7xkw="; # signs user certs — servers trust this
  sshHostCAPublicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHki+GhZun8wywCyEtr0//baGNFJXddJj6TEWh1M5A6yHcSYn7hdtqdj5XkCuv8WjiRjH6a17AewwnHDHpMz3bw="; # signs host certs — clients trust this
  rootCAPem = ''
    -----BEGIN CERTIFICATE-----
    MIIBpTCCAUqgAwIBAgIRALevKnnElllot/cRNGjnUqUwCgYIKoZIzj0EAwIwMDES
    MBAGA1UEChMJU2F1bW9uTmV0MRowGAYDVQQDExFTYXVtb25OZXQgUm9vdCBDQTAe
    Fw0yMjA0MjQyMDAxNDlaFw0zMjA0MjEyMDAxNDlaMDAxEjAQBgNVBAoTCVNhdW1v
    bk5ldDEaMBgGA1UEAxMRU2F1bW9uTmV0IFJvb3QgQ0EwWTATBgcqhkjOPQIBBggq
    hkjOPQMBBwNCAAQG356Ui437dBTSOiJILKjVkwrJMsXN3eba/T1N+IJeqRBfigo7
    BW9YZfs1xIbMZ5wL0Zc/DsSEo5xCC7j4YaXro0UwQzAOBgNVHQ8BAf8EBAMCAQYw
    EgYDVR0TAQH/BAgwBgEB/wIBATAdBgNVHQ4EFgQUFY5Ad7h4B6i2FBOZM0qIb+kC
    jAYwCgYIKoZIzj0EAwIDSQAwRgIhALdsEqiRa4ak5Cnin6Tjnel5uOiHSjoC6LKf
    VfXtULncAiEA2gmqdr+ugFz5tvPdKwanroTiMTUMhhCRYVlQlyTApyQ=
    -----END CERTIFICATE-----'';
}
