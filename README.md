# My NixOS Configurations ❄ 

[![Build Status](https://ci.julienmalka.me/api/badges/JulienMalka/nix-config/status.svg?ref=refs/heads/main)](https://ci.julienmalka.me/JulienMalka/nix-config)

This repository contains the configurations of my machines using NixOS. 

### *What is NixOS ?*

NixOS is a linux distribution based on the Nix package manager. It allows fully reproducible builds and a declarative configuration style, using a functionnal langage called Nix (yes, it is the same name as the package manager and the OS).

### *What is a flake ?*

This whole repository is a flake. It is an experimental feature of Nix, allowing for pure evaluation of code. Dependency are fully specified and locked.

### *How does this work ?*

#### Machines 

This project manage the configuration of three machines :
- **Macintosh**, a thinkpad laptop,
- **Lisa**, a high performance server,
- **Newton**, a low performance stockage server.

Machines configurations are located in the machines folder, and are using all the custom modules defined in this project.

#### Modules

This configuration defines a number of custom NixOS and home-manager modules. They are respectively defined in the modules and home-manager-modules folders.

#### Secrets

Secrets are stored in the secrets folder. They are uncrypted upon system activation using the host ssh key. Secrets are managed using nix-sops.

### Inspirations 

This project is freely inspired by some really cool projects, including MayNiklas/nixos, pinox/nixos and ncfavier/config.
