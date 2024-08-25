let
  gustave = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJrHUzjPX0v2FX5gJALCjEJaUJ4sbfkv8CBWc6zm0Oe";
  tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA9QGKzHJ5/PR/il8REaTxJKB4G2LEEts0BlcVz789lt";
  lisa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4kSscukEEoW/QiLgyZQluhsYK4wF+lFphlCakKYC2q";
  core-security = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLnOINGYOFb+bLUUTV9sjwi2qbpwcaQlmGmWfy1PeGR";
  x2100 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG/zyse3NaSi9nxMSZ9ICYe4MMjUka+DewJ5M5N8cCBy";
  fischer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPeKDFxgdZlhNXEUx8ex0Fj2Re+tDBvUr52SS4Wh3V9n";
  core-data = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAcIdJ3gr17bvDZ8NAcDBkEmOPTEhpg2yq3p1NNQB0f";
  lambda = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKluGTi+vGRLU2emYBhTJuEy7Qw0xq1e0Ey7wvU9xYHz";
  nuage = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtPoZXJKPfSPGYb/H9eWL0tNSpAKM6V/AgeE1Uf2Is6";
  enigma = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBgBNhXqFN79KUpmey44pag2FQYVulf1gYnRjdbvkzWW";
  akhaten = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5W1rr+VW2TLLytoTExWg4T14lrdLFkSM4YLfbEIb2g";
  servers = [
    gustave
    tower
    lisa
    core-security
    lambda
    core-data
    nuage
    akhaten
  ];
  all = servers ++ [
    x2100
    fischer
    enigma
  ];
in
{
  "deluge-webui-password.age".publicKeys = [
    gustave
    tower
  ];
  "keycloak-db.age".publicKeys = [
    core-security
    tower
  ];
  "github-oauth-secret.age".publicKeys = [ tower ];
  "github-webhook-secret.age".publicKeys = [ tower ];
  "github-token-secret.age".publicKeys = [ tower ];
  "buildbot-nix-worker-password.age".publicKeys = [ tower ];
  "buildbot-nix-workers.age".publicKeys = [ tower ];
  "ssh-lisa-pub.age".publicKeys = [
    lisa
    tower
  ];
  "ssh-lisa-priv.age".publicKeys = [
    lisa
    tower
  ];
  "git-gpg-private-key.age".publicKeys = servers ++ [
    x2100
    fischer
    enigma
  ];
  "user-julien-password.age".publicKeys = all;
  "user-root-password.age".publicKeys = all;
  "ens-mail-password.age".publicKeys = servers ++ [
    x2100
    fischer
  ];
  "julien-malka-sh-mail-password.age".publicKeys = [
    lisa
    tower
  ];
  "malka-ens-school-mail-password.age".publicKeys = [
    lisa
    tower
  ];
  "mondon-ens-school-mail-password.age".publicKeys = [
    lisa
    tower
  ];
  "forgejo_runners-token_file.age".publicKeys = [ tower ];
  "stalwart-admin.age".publicKeys = [
    tower
    akhaten
  ];
}
