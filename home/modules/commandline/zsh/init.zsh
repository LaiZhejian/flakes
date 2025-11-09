#proxy list
myproxy=http://127.0.0.1:6152
myproxy_on() {
  export https_proxy="${myproxy}"
  export http_proxy="${myproxy}"
  export all_proxy="${myproxy}"
  export HTTPS_PROXY="${myproxy}"
  export HTTP_PROXY="${myproxy}"
  export ALL_PROXY="${myproxy}"
  git config --global http.proxy "${myproxy}"
  git config --global https.proxy "${myproxy}"
}
myproxy_off() {
  unset https_proxy http_proxy all_proxy HTTPS_PROXY HTTP_PROXY ALL_PROXY
  git config --global --unset http.proxy
  git config --global --unset https.proxy
}
# myproxy_on

campusproxy_on() {
  sudo easytier-core -c "/Users/dream/Library/Mobile Documents/iCloud~com~nssurge~inc/Documents/easytier.toml"
}

# download model
alias download="python /Users/dream/Documents/coding/ConductingExp/util/download_model.py"

# brew
alias abrew="arch -arm64 /opt/homebrew/bin/brew"
export HOMEBREW_NO_AUTO_UPDATE=true
export HOMEBREW_NO_INSTALL_CLEANUP=true

# huggingface
export HF_ENDPOINT=https://hf-mirror.com
export HF_HUB_ENABLE_HF_TRANSFER=0
hf_download() {
  huggingface-cli download --token $(cat ~/.tokens/huggingface) "$@"
}

export GIT_TEST_ASSUME_DIFFERENT_OWNER=true
export WANDB_DISABLED=true
