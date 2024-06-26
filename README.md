# My NixOS Configurations ❄ 
[![Build status](https://ci.julienmalka.me/badges/JulienMalka_snowfield_nix-eval.svg)](https://ci.julienmalka.me/#/builders/16) [![built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://builtwithnix.org)

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


