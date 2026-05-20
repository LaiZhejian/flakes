<div align="center">
<table>
<thead>
<tr>
<th style="text-align: center;">main</th>
<th style="text-align: center;">dev</th>
<th style="text-align: center;">daily</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><a href="https://github.com/Undefined01/flakes/actions/workflows/build-test.yml"><img src="https://github.com/Undefined01/flakes/actions/workflows/build-test.yml/badge.svg?branch=main" alt="Build Test" /></a></td>
<td align="center"><a href="https://github.com/Undefined01/flakes/actions/workflows/build-test.yml"><img src="https://github.com/Undefined01/flakes/actions/workflows/build-test.yml/badge.svg?branch=dev" alt="Build Test" /></a></td>
<td align="center"><a href="https://github.com/Undefined01/flakes/actions/workflows/build-test.yml"><img src="https://github.com/Undefined01/flakes/actions/workflows/build-test.yml/badge.svg?branch=bot%2Fdev-lock" alt="Build Test" /></a></td>
</tr>
</tbody>
</table>
</div>

## Flake Setup

1. Install Nix

    - **NixOS / WSL-NixOS**: Nix is already present.
    - **Other Linux / macOS**:
        ```bash
        curl -fsSL https://install.determinate.systems/nix | sh -s -- install --prefer-upstream-nix
        ```

        **Uninstall** if needed:
        ```
        /nix/nix-installer uninstall
        ```

    To temporarily enable flakes and third-party substituters (ensure you are a trusted Nix user, e.g. root):
    ```bash
    export NIX_CONFIG="
    extra-experimental-features = nix-command flakes pipe-operators
    substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/ https://nix-community.cachix.org https://undefined01.cachix.org
    trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= undefined01.cachix.org-1:9ZQ59dYp2cR8S5p87DaKqjtIyjZ1qMHmM2JtzpQl1dU=
    "
    ```

2. Clone the repository

    ```bash
    git clone --recursive https://github.com/undefined01/flakes
    cd flakes
    git submodule update --init --recursive
    ```

    If `git` is missing, you can enter a temporary shell with `nix --extra-experimental-features "nix-command flakes" shell nixpkgs#git`.

3. Apply the configuration

    - **NixOS / WSL-NixOS** (nixosConfiguration):
        ```bash
        sudo -E nixos-rebuild switch --flake ".?submodules=1#wsl"
        ```
        Change the profile after `#` to pick another, e.g. `.?submodules=1#work`.

        You may need hardware info first:
        ```bash
        sudo -E nix shell nixpkgs#nixos-install-tools --command nixos-generate-config --show-hardware-config > hardware-configuration.nix
        sudo -E nix run nixpkgs#nixos-facter > facter.json
        ```

    - **Other Linux (Home Manager)**:
        ```bash
        sudo -E nix run home-manager -- switch --flake ".?submodules=1#lh"
        ```
        Home-Manager only manages user-level configuration, so you may want to manually create or edit `/etc/nix/nix.conf` to modify system-wide Nix settings:
        ```
        extra-experimental-features = nix-command flakes pipe-operators
        trusted-users = root @admin @sudo @wheel
        substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/ https://nix-community.cachix.org https://undefined01.cachix.org
        trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= undefined01.cachix.org-1:9ZQ59dYp2cR8S5p87DaKqjtIyjZ1qMHmM2JtzpQl1dU=
        ```
        If the `nix` command disappears after an incomplete rebuild, try restore it with:
        ```bash
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        ```

    - **macOS (darwinConfiguration)**:
        ```bash
        sudo -E nix run nix-darwin -- switch --flake ".?submodules=1#darwin"
        sudo darwin-rebuild switch --flake ".?submodules=1#darwin"
        ```
        You may need `killall Dock` or system reboot to make the system preference changes take effect.

## Known Issues


- [ ] [Sparkle package](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/sp/sparkle/package.nix) is refactored and only supports Linux now. This repo downloads the prebuilt-binary from [Github Releases](https://github.com/xishang0128/sparkle/releases) for darwin.

- [x] In fish, the recommended wrapper for yazi uses `builtin cd`, which does not trigger the recording of directory history.

    Current fix: override the generated wrapper in [home/modules/commandline/yazi/default.nix](home/modules/commandline/yazi/default.nix), and switch to plain `cd` after reading `--cwd-file`.

    References: [home-manager yazi module source](https://github.com/nix-community/home-manager/blob/0d02ec1d0a05f88ef9e74b516842900c41f0f2fe/modules/programs/yazi.nix#L235), [issue #2859](https://github.com/sxyazi/yazi/issues/2859).

<!--
Templates:

- None so far.

- [ ] Sparkle (a mihomo client) has been deleted. The latest release is recovered temporarily. Waiting for future update. [![](https://img.shields.io/github/pulls/detail/state/NixOS/nixpkgs/485640)](https://github.com/NixOS/nixpkgs/pull/485640)

- [x] Obsidian doesn't allow empty settings yet. [![](https://img.shields.io/github/pulls/detail/state/nix-community/home-manager/8562)](https://github.com/nix-community/home-manager/pull/8562)
-->

## Useful Commands

- Search: [NixOS packages](https://search.nixos.org/packages), [NixOS options](https://search.nixos.org/options), [nix-darwin option manual](https://nix-darwin.github.io/nix-darwin/manual/), [Home Manager options](https://home-manager-options.extranix.com/), [Searchix (NixOS, nix-darwin, Home Manager, and NUR)](https://searchix.ovh), [Nixpkgs lib](https://noogle.dev/)
- [Nixpkgs Tracker](https://nixpkgs-tracker.ocfox.me/): Check if a PR is merged to the following branches. 
- [EmergentMind's config](https://github.com/EmergentMind/nix-config)
- Format nix files in the current tree:
    ```
    nix fmt .
    ```

    Install a git-hook:

    ```
    cat >.git/hooks/pre-commit <<<EOF
    #!/bin/bash
    set -e

    nix fmt -- --ci
    EOF
    ```
- Test configurations without building or fetching cache

    ```
    nix build --no-link --print-build-logs .#darwinConfigurations.darwin.system --dry-run
    ```
- Merge [the updates from daily](https://github.com/Undefined01/flakes/compare/dev...bot/dev-lock):

    ```
    git fetch origin bot/dev-lock
    git merge --squash origin/bot/dev-lock
    ```
- Debug a package:

    The builder script for stdenv: https://github.com/NixOS/nixpkgs/blob/master/pkgs/stdenv/generic/setup.sh

    ```bash
    nix-shell default.nix -A package
    # or: nix develop .#package

    cd $(mktemp -d)
    
    genericBuild
    
    # or run phases one by one:
    printPhases
    runPhase unpackPhase
    runPhase patchPhase
    runPhase configurePhase
    runPhase buildPhase
    runPhase checkPhase
    runPhase installPhase
    runPhase fixupPhase
    runPhase installCheckPhase
    runPhase distPhase

    # inspect the build phase script
    function inspect() {
        echo "${!1:-$(type $1)}"
    }
    inspect buildPhase
    ```
- Set up secrets:
    ```
    nix run nixpkgs#sops home/secrets/common.yaml
    bash -c 'cd home/secrets/; nix run .#agenix -- -e common.age'
    ```
- Update mutable-home-files manually:
    ```
    nix eval --json .#darwinConfigurations.darwin.config.home-manager.users.han.home.mutableFileInternal.taskPayload | tee /tmp/payload.json
    nix run github:Undefined01/mutable-home-files -- --task-file /tmp/payload.json
    ```
- Visualize the Nix store:
    ```
    nix run github:utdemir/nix-tree
    nix shell nixpkgs#{bash,graphviz,nix-du} -c bash -c 'nix-du | dot -Tpng > store.png'
    ```
- Build an ISO image:
    ```
    nix build .#nixosConfigurations.iso.config.system.build.isoImage
    ```
- One-off proxy for CLI tools (current shell only):
    ```
    export {http_proxy,https_proxy,HTTP_PROXY,HTTPS_PROXY,all_proxy,ALL_PROXY}="http://127.0.0.1:7890"
    ```
- Temporary proxy for the Nix daemon (lost on reboot):
    ```bash
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
- Garbage collect old system generations (ensure the latest build boots):
    ```
    sudo nix-collect-garbage --delete-old
    ```
