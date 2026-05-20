{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    config = {
      whitelist = {
        prefix = [ ];

        exact = [ ];
      };
    };
  };

  programs.git.ignores = [
    ".direnv/"
    ".envrc"
  ];
}
