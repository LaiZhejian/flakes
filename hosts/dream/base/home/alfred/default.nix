{
  config,
  lib,
  pkgs,
  ...
}:

let
  workflowDirectory = "${config.home.homeDirectory}/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows";
  workflows = {
    "user.workflow.E97AD599-94DF-4C0E-86A9-15EFD81BA651" = "VSCode---Open-Project.alfredworkflow";
    "user.workflow.25888CC3-2A6D-4978-B5A0-5CE3A497ED03" = "Eudic.alfredworkflow";
    "user.workflow.788283DF-E783-4FDB-83CA-6C91F291C4B4" = "Visual-Studio-Code.alfredworkflow";
    "user.workflow.C8B9C759-0D8F-47A0-9C25-BA3175F45399" = "PyCodeVar.alfredworkflow";
    "user.workflow.D124DD74-3F45-4D5B-AEA9-5FC3E6B90B18" = "进制转换.alfredworkflow";
    "user.workflow.D0FCAC6B-643C-44B8-9DD2-5BB37CEDF400" = "Quick-Open-URL.alfredworkflow";
    "user.workflow.D1481E4C-D7D9-45EE-9458-0DE3E28314C1" = "DNS-Selector.alfredworkflow";
    "user.workflow.B40B7137-70CF-4F7F-9436-630A1D013C9E" = "Template-File.alfredworkflow";
    "user.workflow.1DA1D0F7-47FA-4770-923D-195FE63B38A4" = "ssh.alfredworkflow";
    "user.workflow.9AE26DA0-6310-4BBC-BA06-003091E5AD98" = "CodeVar.alfredworkflow";
    "user.workflow.7F5920E2-9389-481F-940C-2D7DF815CCE2" = "IP-Address.alfredworkflow";
    "user.workflow.5099304D-1186-4E8F-B201-EC452DF56198" = "ZotHero.alfredworkflow";
    "user.workflow.A4B34DA5-4F2F-4206-BFF9-373319485066" = "1Password.alfredworkflow";
    "user.workflow.03A444FB-05FF-41F9-8C6D-8F094EE39CD4" = "HTTP-Status-Code.alfredworkflow";
    "user.workflow.16E253F3-7FDE-43CB-9710-43E6D9709157" = "JSON-View.alfredworkflow";
  };
  installWorkflow = workflowId: archive: ''
    $DRY_RUN_CMD mkdir -p "${workflowDirectory}/${workflowId}"
    $DRY_RUN_CMD ${lib.getExe pkgs.unzip} -oq \
      "${config.home.homeDirectory}/.local/share/alfred-workflows/${archive}" \
      -d "${workflowDirectory}/${workflowId}"
  '';
in
{
  home.file.".local/share/alfred-workflows" = {
    source = ./workflows;
    recursive = true;
  };

  home.activation.installAlfredWorkflows = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    ''
      # Use Alfred's local preferences. Only workflows are managed here.
      $DRY_RUN_CMD /usr/bin/defaults delete \
        com.runningwithcrayons.Alfred-Preferences syncfolder 2>/dev/null || true
      $DRY_RUN_CMD mkdir -p "${workflowDirectory}"
    ''
    + lib.concatStrings (lib.mapAttrsToList installWorkflow workflows)
  );
}
