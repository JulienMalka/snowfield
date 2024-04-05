#!/usr/bin/env bash

# Create a temporary directory
temp=$(mktemp -d)
machine=$1
ip=$2
# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/etc/ssh"

# Decrypt your private key from the password store and copy it to the temporary directory
rbw get "$machine"_ssh_host_ed25519_key -f notes > "$temp/etc/ssh/ssh_host_ed25519_key"

# Set the correct permissions so sshd will accept the key
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

nixos-anywhere --extra-files "$temp" --store-paths $(nix-build -A nixosConfigurations.\"$machine\".config.system.build.toplevel) $(nix-build -A nixosConfigurations.\"$machine\".config.system.build.diskoScript) root@"$ip"
