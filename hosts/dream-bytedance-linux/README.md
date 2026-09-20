# Dream ByteDance Linux / Forge

Dream-owned standalone Home Manager configuration for an x86_64 Ubuntu/Forge
development container. This does not install NixOS or import Dream's Darwin
configuration. The default account is `root` with home `/root`; edit `meta.nix`
before deploying for another account (home then defaults to `/home/<username>`).

Manages CLI tools, zsh/Oh My Zsh, Starship, Git/gitui, tmux, Codex, kubectl and
the ByteDance uv index. `~/.local/bin` remains available for company tools.
`coco` is intentionally excluded from this configuration and remains managed
outside this flake.

Does not manage SSH files, keys, authentication agents, AI account credentials,
VS Code Server, macOS applications or CUDA. Existing project environments are
not changed during activation. uv uses manual Python downloads; explicit uv
commands may still create or update project environments. Company package
access requires the appropriate network and existing authentication.

## Deployment

Run from the repository root on the target Linux machine with Nix installed.
For the default root container, use the local store rather than a daemon:

```sh
export NIX_REMOTE=local
nix --extra-experimental-features 'nix-command flakes pipe-operators' build \
  'path:.#homeConfigurations.dream-bytedance-linux.activationPackage' \
  --out-link result-dream-bytedance-linux
./result-dream-bytedance-linux/activate
```

The same commands apply subsequent changes using the repository's pinned
inputs. For a non-root account, omit the `NIX_REMOTE=local` export and use the
machine's existing Nix store setup. The profile only persists that variable
for root. Open a new shell after activation; run `zsh` to enter zsh. No system
login-shell change is performed.

Review any Home Manager file-collision errors and preserve existing content
before trying activation again. Sign in to Codex separately on the container
if credentials are not already present; no local account state is copied.
