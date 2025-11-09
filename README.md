# Installation

1. Install Nix package manager
   
   a. For NixOS or WSL-NixOS

      They are included in the system. No need to install seperately.

   b. For other Linux distribution and macOS

     ```bash
     sh <(curl -L https://nixos.org/nix/install)
     ```

3. Clone this repo

   If git is not installed, you can use git temporarily in the nix shell `nix --extra-experimental-features "nix-command flakes" shell nixpkgs#git`.

   ``` bash
   git clone --recursive https://github.com/undefined01/flakes
   cd flakes
   git submodule update --init --recursive
   ```

4. Switch to this configuration

   a. For NixOS or WSL-NixOS, the nixosConfiguration is applied.

      ```bash
      sudo nixos-rebuild switch --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store https://nix-community.cachix.org https://cache.nixos.org/" --flake ".?submodules=1#wsl"
      ```
    
      You can select the profile to switch to by changing the name after the hashtag, e.g. `.?submodules=1#work`.

   b. For other Linux distribution, the homeConfiguration is applied.

      ```bash
      sudo nix --extra-experimental-features 'nix-command flakes' run home-manager/master -- switch --flake ".?submodules=1#lh"
      ```

      nix cannot change the system-wide configurations for non-NixOS distributions. You have to change the nix configuration manually. It is usually placed at `/etc/nix/nix.conf`.

      ```
      experimental-features = nix-command flakes
      substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/
      ```

      If your nix command are missing, try `. ~/.nix-profile/etc/profile.d/nix.sh` to recover the access to nix command.

   c. For macOS, the darwinConfiguration is applied.

      ```bash
      sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake ".?submodules=1#darwin"
      ```

      After installation, you can rebuild the configuration by darwin-rebuild

      ```bash
      sudo darwin-rebuild switch --flake ".?submodules=1#darwin"
      ```

# Known Issues

- Immersive Translate extension may not work as expected.

# Useful Commands

```
# set up the proxy
export {http_proxy,https_proxy,HTTP_PROXY,HTTPS_PROXY,all_proxy,ALL_PROXY}="http://172.25.64.1:7891"

# update submodules
git submodule update --init --recursive

# Formatting code
nix fmt .

# System-wide garbage collection, make sure your latest system build can boot successfully before removing old generations.
nix-collect-garbage --delete-old

# Setting up secrets for nix
nix run nixpkgs#sops home/secrets/common.yaml
bash -c 'cd home/secrets/; nix run .#agenix -- -e common.age

# visualize the Nix store and its size
nix run github:utdemir/nix-tree
nix shell nixpkgs#{bash,graphviz,nix-du} -c bash -c 'nix-du | dot -Tpng > store.png'

# Build an ISO image
nix build .#nixosConfigurations.iso.config.system.build.isoImage

# Set up a temporary proxy for the Nix daemon. Note that this configuration will be lost after a reboot.
# It is recommended to enable TUN mode in your proxy software to capture all traffic.
sudo bash -c '
PROXY="http://localhost:7891"
mkdir -p /run/systemd/system/nix-daemon.service.d
cat << EOF >/run/systemd/system/nix-daemon.service.d/override.conf  
[Service]
Environment="http_proxy=$PROXY"
Environment="https_proxy=$PROXY"
Environment="all_proxy=$PROXY"
EOF
systemctl daemon-reload
systemctl restart nix-daemon
'
```
