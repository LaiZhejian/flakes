# Non-host changes relative to upstream/main

Baseline: `upstream/main` at `ab9a6d2`.

This inventory intentionally does not reproduce secrets or the contents of the
macOS defaults dump. It records every current difference outside `hosts/**` so
that each item can be migrated into `hosts/dream`, accepted from upstream, or
discarded deliberately.

## Progress

Completed after the initial inventory:

- Deleted `a.txt`.
- Accepted upstream's `flake.lock`.
- Accepted upstream's Claude Code, Codex, SSH, input-method and VS Code modules.
- Accepted upstream's Sparkle package version.
- Updated the Neovim submodule to upstream's locked commit.
- Removed the duplicate shared Fish and Zsh init files; Dream's copies remain
  under `hosts/dream`.
- Migrated the old `darwin-b`/`bytedance` configuration to
  `hosts/dream-bytedance`, inheriting Dream's current host defaults.
- Decision: keep all five Dream Zsh plugin submodules and their `.gitmodules`
  entries.
- Kept `.claude/settings.local.json` on this machine, removed it from Git
  tracking, ignored it through `.git/info/exclude`, and removed obsolete
  permissions for the pre-refactor `home/modules` paths.
- Personalized the final profiles in `hosts/dream`: Claude and Starship stay
  enabled; LSP and rclone are disabled; GitUI is the only Git UI. Codex, VS
  Code, Zotero, QQ, WeChat, and the three Homebrew casks are limited to the
  personal Dream host and are not enabled on Dream's ByteDance host.

The remaining non-host differences are limited to machine-local Claude
settings, `.DS_Store` ignore policy, and Dream's Zsh plugin sources.

## Summary

- Initial inventory: 24 changed paths outside `hosts/**`
- Remaining after the first cleanup pass: 10 paths
- The large historical directory refactor is already present upstream and is
  not a real local deviation.

## Likely personal configuration to migrate into hosts/dream

| Path | Current local behavior | Suggested destination |
| --- | --- | --- |
| `.gitignore` | Adds `.DS_Store` | Keep only if desired; harmless shared hygiene change |
| `.gitmodules` | Adds five Zsh plugin submodules | Replace with packages/flake inputs if possible, or keep plugin sources under `hosts/dream` |
| `home/commandline/fish/init.fish` | Personal Fish initialization | Already represented by `hosts/dream/init.fish`; remove shared copy |
| `home/commandline/zsh/init.zsh` | Personal Zsh initialization | Already represented by `hosts/dream/init.zsh`; remove shared copy |
| `home/commandline/zsh/plugins/*` | Five personal Zsh plugin submodules | Reference from `hosts/dream`, preferably without changing shared `.gitmodules` |
| `system/presets/users/dream.nix` | Old-layout Dream user definition | Superseded by `hosts/dream/system.nix` and `meta.nix` |
| `system/top/darwin/darwin-b.nix` | Old-layout Darwin host, including `bytedance` overrides | Migrate only if this is still a second active machine |

The five Zsh plugin paths are:

- `cmdtime`
- `fzf-ls`
- `fzf-tab`
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`

## Shared-module behavior differences

These are actual local behavioral choices currently made outside `hosts/**`.
They should be expressed as host-level options where the upstream module
supports them. If it does not, prefer requesting/adding a generic option rather
than hard-coding Dream's choice in the shared implementation.

| Path | Local difference from upstream |
| --- | --- |
| `home/commandline/claudecode/default.nix` | Removes mutable management of `.claude.json` and `.claude/settings.json` |
| `home/commandline/claudecode/claude.json` | Deletes upstream onboarding defaults |
| `home/commandline/claudecode/settings.json` | Deletes upstream Claude settings layer |
| `home/commandline/codex/codex.sh` | Uses an unquoted custom base URL argument; upstream quotes it |
| `home/commandline/codex/default.nix` | Removes local ownership for `tui.model_availability_nux` |
| `home/commandline/ssh/default.nix` | Uses `programs.ssh.matchBlocks`; upstream uses `programs.ssh.settings` |
| `home/desktop/input/default.nix` | Uses plain `fcitx5-rime`; upstream enables `rime-wanxiang` |
| `home/desktop/vscode/default.nix` | Adds `github.copilot` and restores terminal scrollback to 100,000 |

Notes:

- Dream currently disables Codex and all desktop stacks, so the Codex, input,
  and VS Code deviations may no longer affect this host.
- Dream's SSH override already lives in `hosts/dream/home.nix`; the shared SSH
  implementation can normally follow upstream.

## Version pins that are simply older than upstream

| Path | Local state | Upstream state |
| --- | --- | --- |
| `flake.lock` | Older Homebrew, nix-darwin, Home Manager, Nixpkgs, NUR, sops-nix, NixOS-WSL and related inputs | Newer lock revisions |
| `home/commandline/neovim/nvim-config` | Submodule `01e681f` | Submodule `daac78f` |
| `pkgs/darwinPkgs/sparkle-bin/package.nix` | Sparkle `1.26.4` | Sparkle `1.26.5` |

Unless a regression is known, these should follow upstream.

## Local or sensitive artifacts that should not be committed

| Path | Reason |
| --- | --- |
| `.claude/settings.local.json` | Machine-local Claude permissions/settings |
| `a.txt` | 5.6 MB full macOS defaults export containing account, application and device metadata |
| `home/commandline/codex/codex.sh` | The working copy has contained hard-coded API credentials; credentials should be rotated and supplied through SOPS/environment configuration |

## Recommended disposition

1. Preserve `hosts/dream/**`.
2. Decide whether `system/top/darwin/darwin-b.nix` represents a second active
   Dream machine; if yes, convert it into another directory under
   `hosts/dream/`.
3. Decide how to source the five Zsh plugins without changing shared module
   paths.
4. Keep `.claude/settings.local.json` untracked and remove `a.txt` from the
   repository state.
5. Accept upstream for the lock file, Neovim submodule, Sparkle package and
   shared implementations unless a specific local behavior is still required.
