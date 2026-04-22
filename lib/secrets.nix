lib:

{
  # Aggregates every agenix secret declared across all managed hosts into a
  # single flat attrset keyed by the absolute path of the source .age file.
  # Each entry is annotated with a `targets` list naming the machines (and
  # home-manager user slots, suffixed `_home`) that need to decrypt it.
  #
  # Consumed by secrets/secrets.nix to compute `publicKeys` per secret — the
  # single source of truth agenix uses when re-encrypting.
  #
  # The `_home` suffix convention assumes one home-manager user slot per host,
  # which matches our setup. Add the user name if that ever changes.
  collectSecrets =
    nixosConfigurations:
    let
      systemSecrets = lib.mapAttrsToList (
        name: machine:
        lib.mapAttrs' (
          _: secret: lib.nameValuePair (builtins.toString secret.file) (secret // { targets = [ name ]; })
        ) machine.config.age.secrets
      ) nixosConfigurations;

      hmSecrets = lib.concatLists (
        lib.mapAttrsToList (
          name: machine:
          lib.mapAttrsToList (
            _user: userCfg:
            lib.mapAttrs' (
              _: secret:
              lib.nameValuePair (builtins.toString secret.file) (secret // { targets = [ "${name}_home" ]; })
            ) userCfg.age.secrets
          ) machine.config.home-manager.users
        ) nixosConfigurations
      );
    in
    lib.foldl lib.deepMerge { } (systemSecrets ++ hmSecrets);
}
