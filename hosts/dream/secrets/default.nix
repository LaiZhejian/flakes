{
  config,
  inputs,
  lib,
  ...
}:

let
  secretNames = [
    "HUGGINGFACE_TOKEN"
    "WAKATIME_API_KEY"
    "ZOTERO_EASYSCHOLAR_API_KEY"
    "ZOTERO_GPT_API_KEY"
    "ZOTERO_GPT_EMBEDDINGS_API_KEY"
  ];
  secret = name: config.sops.placeholder.${name};
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ./api-keys.yaml;
    secrets = lib.genAttrs secretNames (_: { }) // {
      SSH_ID_RSA = {
        sopsFile = ./ssh-keys.yaml;
      };
      SSH_EXP_SERVER = {
        sopsFile = ./ssh-keys.yaml;
      };
    };

    templates = {
      "api-keys.env" = {
        path = "${config.home.homeDirectory}/.config/secrets/api-keys.env";
        mode = "0400";
        content = ''
          HUGGINGFACE_TOKEN=${secret "HUGGINGFACE_TOKEN"}
          WAKATIME_API_KEY=${secret "WAKATIME_API_KEY"}
          ZOTERO_EASYSCHOLAR_API_KEY=${secret "ZOTERO_EASYSCHOLAR_API_KEY"}
          ZOTERO_GPT_API_KEY=${secret "ZOTERO_GPT_API_KEY"}
          ZOTERO_GPT_EMBEDDINGS_API_KEY=${secret "ZOTERO_GPT_EMBEDDINGS_API_KEY"}
        '';
      };

      "huggingface-token" = {
        path = "${config.home.homeDirectory}/.tokens/huggingface";
        mode = "0400";
        content = secret "HUGGINGFACE_TOKEN";
      };

      "wakatime.cfg" = {
        path = "${config.home.homeDirectory}/.wakatime.cfg";
        mode = "0400";
        content = ''
          [settings]
          api_key = ${secret "WAKATIME_API_KEY"}
        '';
      };

      "zotero-secrets.js" = {
        mode = "0400";
        content = ''
          user_pref("extensions.zotero.zoterogpt.secretKey", "${secret "ZOTERO_GPT_API_KEY"}");
          user_pref("extensions.zotero.zoterogpt.embeddings.secretKey", "${secret "ZOTERO_GPT_EMBEDDINGS_API_KEY"}");
          user_pref("extensions.zotero.zoterostyle.easyscholar.secretKey", "${secret "ZOTERO_EASYSCHOLAR_API_KEY"}");
        '';
      };

      "ssh-id-rsa" = {
        path = "${config.home.homeDirectory}/.ssh/id_rsa";
        mode = "0600";
        content = ''
          ${secret "SSH_ID_RSA"}
        '';
      };

      "ssh-exp-server" = {
        path = "${config.home.homeDirectory}/.ssh/exp_server";
        mode = "0600";
        content = ''
          ${secret "SSH_EXP_SERVER"}
        '';
      };
    };
  };

  # Zotero generates a random profile directory. Link the secret preferences
  # into every default profile that currently exists instead of hard-coding a
  # machine-specific profile ID. On a fresh machine, launch Zotero once and
  # re-run the Home Manager activation.
  home.activation.linkZoteroSecrets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    zotero_profiles="${config.home.homeDirectory}/Library/Application Support/Zotero/Profiles"
    if [ -d "$zotero_profiles" ]; then
      for zotero_profile in "$zotero_profiles"/*.default*; do
        if [ -d "$zotero_profile" ]; then
          $DRY_RUN_CMD ln -sfn ${
            config.sops.templates."zotero-secrets.js".path
          } "$zotero_profile/user.js"
        fi
      done
    fi
  '';
}
