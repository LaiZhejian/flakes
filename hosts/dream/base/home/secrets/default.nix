{
  config,
  inputs,
  lib,
  ...
}:

let
  secretNames = [
    "DEEPSEEK_API_KEY"
    "HUGGINGFACE_TOKEN"
    "WAKATIME_API_KEY"
    "ZOTERO_API_KEY"
    "ZOTERO_EASYSCHOLAR_API_KEY"
    "ZOTERO_GPT_API_KEY"
    "ZOTERO_GPT_EMBEDDINGS_API_KEY"
    "ZOTERO_PDF_TRANSLATE_CNKI_TOKEN"
    "ZOTERO_PDF_TRANSLATE_SECRET_OBJ"
    "ZOTERO_USERNAME"
    "ZOTERO_WEBDAV_PASSWORD"
    "ZOTERO_WEBDAV_URL"
    "ZOTERO_WEBDAV_USERNAME"
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

      "claude-code.sh" = {
        path = "${config.home.homeDirectory}/.config/secrets/claude-code/env.sh";
        mode = "0400";
        content = ''
          export ANTHROPIC_BASE_URL='https://api.deepseek.com/anthropic'
          export ANTHROPIC_AUTH_TOKEN='${secret "DEEPSEEK_API_KEY"}'
          export ANTHROPIC_MODEL='deepseek-v4-pro[1m]'
          export ANTHROPIC_DEFAULT_OPUS_MODEL='deepseek-v4-pro[1m]'
          export ANTHROPIC_DEFAULT_SONNET_MODEL='deepseek-v4-pro[1m]'
          export ANTHROPIC_DEFAULT_HAIKU_MODEL='deepseek-v4-flash'
          export CLAUDE_CODE_SUBAGENT_MODEL='deepseek-v4-flash'
          export CLAUDE_CODE_EFFORT_LEVEL='max'
        '';
      };

      "claude-code.fish" = {
        path = "${config.home.homeDirectory}/.config/secrets/claude-code/env.fish";
        mode = "0400";
        content = ''
          set -gx ANTHROPIC_BASE_URL 'https://api.deepseek.com/anthropic'
          set -gx ANTHROPIC_AUTH_TOKEN '${secret "DEEPSEEK_API_KEY"}'
          set -gx ANTHROPIC_MODEL 'deepseek-v4-pro[1m]'
          set -gx ANTHROPIC_DEFAULT_OPUS_MODEL 'deepseek-v4-pro[1m]'
          set -gx ANTHROPIC_DEFAULT_SONNET_MODEL 'deepseek-v4-pro[1m]'
          set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL 'deepseek-v4-flash'
          set -gx CLAUDE_CODE_SUBAGENT_MODEL 'deepseek-v4-flash'
          set -gx CLAUDE_CODE_EFFORT_LEVEL 'max'
        '';
      };

      "wakatime.cfg" = {
        path = "${config.home.homeDirectory}/.wakatime.cfg";
        mode = "0400";
        content = ''
          [settings]
          api_key = ${secret "WAKATIME_API_KEY"}
        '';
      };

      "zotero-api.sh" = {
        path = "${config.home.homeDirectory}/.config/secrets/zotero/api.sh";
        mode = "0400";
        content = ''
          export ZOTERO_API_KEY='${secret "ZOTERO_API_KEY"}'
          export ZOTERO_USER_ID='10270346'
        '';
      };

      "zotero-api.fish" = {
        path = "${config.home.homeDirectory}/.config/secrets/zotero/api.fish";
        mode = "0400";
        content = ''
          set -gx ZOTERO_API_KEY '${secret "ZOTERO_API_KEY"}'
          set -gx ZOTERO_USER_ID '10270346'
        '';
      };

      "zotero-secrets.js" = {
        mode = "0400";
        content = ''
          user_pref("extensions.zotero.flake.secretDirectory", "${config.home.homeDirectory}/.config/secrets/zotero");

          user_pref("extensions.zotero.sync.storage.protocol", "webdav");
          user_pref("extensions.zotero.automaticTags", false);
          user_pref("extensions.zotero.export.quickCopy.locale", "zh-CN");
          user_pref("extensions.zotero.export.translatorSettings", "{\"exportCharset\":\"UTF-8\",\"exportNotes\":false,\"exportFileData\":false,\"useJournalAbbreviation\":false,\"includeAnnotations\":false}");
          user_pref("extensions.zotero.groups.copyChildFileAttachments", false);
          user_pref("extensions.zotero.groups.copyTags", false);
          user_pref("extensions.zotero.itemPaneHeader", "bibEntry");

          user_pref("extensions.jasminum.attachment", "pdf");
          user_pref("extensions.jasminum.citefield", "extra");
          user_pref("extensions.jasminum.disableZoteroOutline", false);
          user_pref("extensions.jasminum.pdfmatchfolder", "${config.home.homeDirectory}/Downloads");

          user_pref("extensions.zotero.ZoteroPDFTranslate.annotationTagContent", "Translation");
          user_pref("extensions.zotero.ZoteroPDFTranslate.dictSource", "bingdict");
          user_pref("extensions.zotero.ZoteroPDFTranslate.disabledLanguages", "zh,中文,中文;");
          user_pref("extensions.zotero.ZoteroPDFTranslate.enableAuto", false);
          user_pref("extensions.zotero.ZoteroPDFTranslate.enableHidePopupTextarea", true);
          user_pref("extensions.zotero.ZoteroPDFTranslate.enableNote", false);
          user_pref("extensions.zotero.ZoteroPDFTranslate.enablePopup", false);
          user_pref("extensions.zotero.ZoteroPDFTranslate.targetLanguage", "zh-CN");
          user_pref("extensions.zotero.ZoteroPDFTranslate.titleColumnMode", "result");
          user_pref("extensions.zotero.ZoteroPDFTranslate.translateSource", "cnki");

          user_pref("extensions.zotero.zoterogpt.api", "https://llmapi.paratera.com");
          user_pref("extensions.zotero.zoterogpt.embeddings.api", "https://dashscope.aliyuncs.com/compatible-mode/v1/embeddings");
          user_pref("extensions.zotero.zoterogpt.embeddings.model", "text-embedding-v3");
          user_pref("extensions.zotero.zoterogpt.secretKey", "${secret "ZOTERO_GPT_API_KEY"}");
          user_pref("extensions.zotero.zoterogpt.embeddings.secretKey", "${secret "ZOTERO_GPT_EMBEDDINGS_API_KEY"}");
          user_pref("extensions.zotero.zoterogpt.model", "DeepSeek-V3.2");
          user_pref("extensions.zotero.zoterostyle.easyscholar.secretKey", "${secret "ZOTERO_EASYSCHOLAR_API_KEY"}");
          user_pref("extensions.zotero.zoterostyle.publicationTagsColumn.fields", "sciif, sci, CCF, utd24, ajg, sciBase, ssci, pku, 复合影响因子");

          user_pref("extensions.updateifs.add-update", true);
          user_pref("extensions.updateifs.ch-abbr", true);
          user_pref("extensions.updateifs.en-abbr", true);
          user_pref("extensions.zotfile.source_dir", "${config.home.homeDirectory}/Downloads");
          user_pref("extensions.zotfile.source_dir_ff", false);
          user_pref("extensions.zotfile.tablet", true);

          user_pref("extensions.zotero.findPDFs.resolvers", "{\"name\":\"Sci-Hub\",\"method\":\"GET\",\"url\":\"https://sci-hub.shop/{doi}\",\"mode\":\"html\",\"selector\":\"#pdf\",\"attribute\":\"src\",\"automatic\":false}");
        '';
      };

      "zotero-username" = {
        path = "${config.home.homeDirectory}/.config/secrets/zotero/username";
        mode = "0400";
        content = secret "ZOTERO_USERNAME";
      };
      "zotero-webdav-username" = {
        path = "${config.home.homeDirectory}/.config/secrets/zotero/webdav-username";
        mode = "0400";
        content = secret "ZOTERO_WEBDAV_USERNAME";
      };
      "zotero-webdav-url" = {
        path = "${config.home.homeDirectory}/.config/secrets/zotero/webdav-url";
        mode = "0400";
        content = secret "ZOTERO_WEBDAV_URL";
      };
      "zotero-webdav-password" = {
        path = "${config.home.homeDirectory}/.config/secrets/zotero/webdav-password";
        mode = "0400";
        content = secret "ZOTERO_WEBDAV_PASSWORD";
      };
      "zotero-pdf-translate-cnki-token" = {
        path = "${config.home.homeDirectory}/.config/secrets/zotero/pdf-translate-cnki-token";
        mode = "0400";
        content = secret "ZOTERO_PDF_TRANSLATE_CNKI_TOKEN";
      };
      "zotero-pdf-translate-secret-obj" = {
        path = "${config.home.homeDirectory}/.config/secrets/zotero/pdf-translate-secret-obj";
        mode = "0400";
        content = secret "ZOTERO_PDF_TRANSLATE_SECRET_OBJ";
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

  # Home Manager's setupLaunchAgents already installs/reloads this agent.
  # The upstream Darwin activation immediately bootouts and bootstraps it
  # again, which races with launchd and intermittently fails with error 5.
  home.activation.sops-nix = lib.mkForce (
    lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
      /bin/launchctl kickstart -k \
        "gui/$(id -u ${config.home.username})/org.nix-community.home.sops-nix"
    ''
  );

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
