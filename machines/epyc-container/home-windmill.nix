_: {
  users.users.windmill.linger = true;

  luj.hmgr.windmill = {
    home.homeDirectory = "/var/lib/windmill-worker";
    home.stateVersion = "25.05";

    programs.git = {
      enable = true;
      maintenance = {
        enable = true;
        repositories = [ "/var/lib/windmill-worker/nixpkgs-mirror.git" ];
      };
    };
  };
}
