# proxy list
set -gx myproxy "http://127.0.0.1:6152"

function myproxy_on
    set -gx https_proxy $myproxy
    set -gx http_proxy $myproxy
    set -gx all_proxy $myproxy
    set -gx HTTPS_PROXY $myproxy
    set -gx HTTP_PROXY $myproxy
    set -gx ALL_PROXY $myproxy

    git config --global http.proxy $myproxy
    git config --global https.proxy $myproxy
end

function myproxy_off
    set -e https_proxy
    set -e http_proxy
    set -e all_proxy
    set -e HTTPS_PROXY
    set -e HTTP_PROXY
    set -e ALL_PROXY

    git config --global --unset http.proxy
    git config --global --unset https.proxy
end

# myproxy_on


# campus proxy
function campusproxy_on
    sudo easytier-core -c "/Users/dream/Library/Mobile Documents/iCloud~com~nssurge~inc/Documents/easytier.toml"
end


# download model
alias download "python /Users/dream/Documents/coding/ConductingExp/util/download_model.py"


# brew
alias abrew "arch -arm64 /opt/homebrew/bin/brew"
set -gx HOMEBREW_NO_AUTO_UPDATE true
set -gx HOMEBREW_NO_INSTALL_CLEANUP true


# huggingface
set -gx HF_ENDPOINT https://hf-mirror.com
set -gx HF_HUB_ENABLE_HF_TRANSFER 0

function hf_download
    huggingface-cli download --token (cat ~/.tokens/huggingface) $argv
end


set -gx GIT_TEST_ASSUME_DIFFERENT_OWNER true
set -gx WANDB_DISABLED true
