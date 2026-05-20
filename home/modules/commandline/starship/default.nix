{ ... }:

{
  imports = [ ./nerd-font-symbols.nix ];

  programs.starship = {
    enable = true;
    # enableTransience = true;
    settings = {
      cmd_duration = {
        disabled = false;
        min_time = 500;
        show_milliseconds = true;
        show_notifications = true;
        min_time_to_notify = 60 * 1000;
        notification_timeout = 3 * 1000;
      };
      time = {
        disabled = false;
      };

      # exit code
      status = {
        disabled = false;
      };

      format = builtins.replaceStrings [ "\\\n" ] [ "" ] ''
        $username\
        $hostname\
        $localip\
        $shlvl\
        $singularity\
        $kubernetes\
        $directory\
        $vcsh\
        $fossil_branch\
        $fossil_metrics\
        $git_branch\
        $git_commit\
        $git_state\
        $git_metrics\
        $git_status\
        $hg_branch\
        $hg_state\
        $pijul_channel\
        $docker_context\
        $package\
        $c\
        $cmake\
        $cobol\
        $daml\
        $dart\
        $deno\
        $dotnet\
        $elixir\
        $elm\
        $erlang\
        $fennel\
        $fortran\
        $gleam\
        $golang\
        $guix_shell\
        $haskell\
        $haxe\
        $helm\
        $java\
        $julia\
        $kotlin\
        $gradle\
        $lua\
        $nim\
        $nodejs\
        $ocaml\
        $opa\
        $perl\
        $php\
        $pulumi\
        $purescript\
        $python\
        $quarto\
        $raku\
        $rlang\
        $red\
        $ruby\
        $rust\
        $scala\
        $solidity\
        $swift\
        $terraform\
        $typst\
        $vlang\
        $vagrant\
        $zig\
        $buf\
        $nix_shell\
        $conda\
        $meson\
        $spack\
        $memory_usage\
        $aws\
        $gcloud\
        $openstack\
        $azure\
        $nats\
        $direnv\
        $env_var\
        $mise\
        $crystal\
        $custom\
        $sudo\
        $cmd_duration\
        $jobs\
        $battery\
        $time\
        $status\
        $line_break\
        $os\
        $container\
        $netns\
        $shell\
        $character\
      '';
    };
  };

  # Transient prompt in fish
  # programs.fish.interactiveShellInit = ''
  #   function starship_transient_prompt_func
  #       switch "$fish_key_bindings"
  #           case fish_hybrid_key_bindings fish_vi_key_bindings
  #               set STARSHIP_KEYMAP "$fish_bind_mode"
  #           case '*'
  #               set STARSHIP_KEYMAP insert
  #       end
  #       set STARSHIP_CMD_PIPESTATUS $pipestatus
  #       set STARSHIP_CMD_STATUS $status
  #       # Account for changes in variable name between v2.7 and v3.0
  #       set STARSHIP_DURATION "$CMD_DURATION$cmd_duration"
  #       set STARSHIP_JOBS (count (jobs -p))
  #       starship prompt --terminal-width="$COLUMNS" --status=$STARSHIP_CMD_STATUS --pipestatus="$STARSHIP_CMD_PIPESTATUS" --keymap=$STARSHIP_KEYMAP --cmd-duration=$STARSHIP_DURATION --jobs=$STARSHIP_JOBS
  #
  #       # starship module directory
  #       # starship module status
  #       # starship module cmd_duration
  #       # starship module time
  #       # starship module line_break
  #       # starship module character
  #   end
  # '';
}
