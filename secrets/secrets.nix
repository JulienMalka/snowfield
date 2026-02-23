let
  self = import ../default.nix;
  inherit (self) all_secrets lib;
  keys = {
    gustave = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJrHUzjPX0v2FX5gJALCjEJaUJ4sbfkv8CBWc6zm0Oe";
    gustave_home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII10x1bM8LQ0KI0eY9uvDhJW9Ic58OH/6uugR1a6OLRE";
    tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA9QGKzHJ5/PR/il8REaTxJKB4G2LEEts0BlcVz789lt";
    lisa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4kSscukEEoW/QiLgyZQluhsYK4wF+lFphlCakKYC2q";
    core-security = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLnOINGYOFb+bLUUTV9sjwi2qbpwcaQlmGmWfy1PeGR";
    arcadia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBR6TATH7NrekBiRk8mMnxNw0LcDzMHgHh/JtpPUCfqT";
    arcadia_home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHH2mPgov6t7oFfEjtZr/DdJW5qSQYqbw+4uYitOCf9n";
    fischer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPeKDFxgdZlhNXEUx8ex0Fj2Re+tDBvUr52SS4Wh3V9n";
    core-data = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAcIdJ3gr17bvDZ8NAcDBkEmOPTEhpg2yq3p1NNQB0f";
    lambda = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKluGTi+vGRLU2emYBhTJuEy7Qw0xq1e0Ey7wvU9xYHz";
    nuage = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtPoZXJKPfSPGYb/H9eWL0tNSpAKM6V/AgeE1Uf2Is6";
    gallifrey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEr9QRD7QTNsAFmuJoX1mFzQ5A2ik1/ogMrvW54JMXeQ";
    gallifrey_home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwMV/IsMl07Oa3Vw8hO4K4YLusREtNhZrYD/81/Bhqr";
    fischer_home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADCpuBL/kSZShtXD6p/Nq9ok4w1DnlSoxToYgdOvUqo";
    akhaten = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5W1rr+VW2TLLytoTExWg4T14lrdLFkSM4YLfbEIb2g";
    biblios = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5//9IlSSuES0xVsqqOwpotfcajgXL0AtcySpoZ8OLJ";
    epyc-container = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINv4nyfI5UOETIG11JqF/jQE6/Rb7v9osmdKlY3PT/fl";
    darillium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBUIJCkSbeFwxDdPJBAS4xhBNEzJ5Kx1yCm1UGRwBMzq";
    darillium_home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN31a7mqOInGOKj6cMeHAgSkoHuqC1xRGgXMGDWgkTPl";
    jacques = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBBgWu3hLZ5Rfp3lH6I03ZabztLo5E8GQhZCWVePNEHe";
  };
  secrets_owners = [
    keys.arcadia
    keys.fischer
    keys.gallifrey
    keys.darillium
  ];
in
lib.mapAttrs (_: v: {
  publicKeys = lib.lists.unique ((map (x: keys."${x}") v.targets) ++ secrets_owners);
}) all_secrets
