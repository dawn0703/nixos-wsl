# ---
# Module: Claude Code Harness
# Description: Anthropic Claude Code CLI agent with alias and non-destructive default settings
# Scope: Home Manager
# ---

{ lib, pkgs, ... }:
let
  claudeWrapped = pkgs.symlinkJoin {
    name = "claude-code-with-alias";
    paths = [ pkgs.claude-code ];
    postBuild = ''
      ln -s $out/bin/claude $out/bin/claude-code
    '';
  };

  claudeDefaults = pkgs.writeText "claude-defaults.json" (builtins.toJSON {
    attribution = {
      commit = "";
      pr = "";
      sessionUrl = false;
    };
    permissions = {
      allow = [
        "Read"
        "Edit"
        "Write"
        "Bash(git status)"
        "Bash(git status *)"
        "Bash(git log)"
        "Bash(git log *)"
        "Bash(git diff)"
        "Bash(git diff *)"
        "Bash(git show *)"
        "Bash(git branch)"
        "Bash(git branch *)"
        "Bash(git checkout *)"
        "Bash(git switch *)"
        "Bash(git add *)"
        "Bash(git commit *)"
        "Bash(ls)"
        "Bash(ls *)"
        "Bash(find *)"
        "Bash(rg *)"
        "Bash(grep *)"
        "Bash(head *)"
        "Bash(tail *)"
        "Bash(wc *)"
        "Bash(node *)"
        "Bash(yarn *)"
        "Bash(npm *)"
        "Bash(npx *)"
        "Bash(python3 *)"
        "Bash(python *)"
        "Bash(pytest *)"
        "Bash(ssh *)"
        "Bash(scp *)"
        "Bash(rsync *)"
        "Bash(git push *)"
        "Bash(git pull *)"
        "Bash(git fetch *)"
        "Bash(hc *)"
        "Bash(herdr *)"
        "Bash(herdr-app *)"
        "Bash(gcc *)"
        "Bash(g++ *)"
        "Bash(make *)"
        "Bash(cmake *)"
        "Bash(bash *)"
        "Bash(sh *)"
        "Bash(mkdir *)"
        "Bash(cp *)"
        "Bash(mv *)"
      ];
      defaultMode = "bypassPermissions";
    };
    enabledPlugins = {
      "pyright-lsp@claude-plugins-official" = true;
      "clangd-lsp@claude-plugins-official" = true;
      "rust-analyzer-lsp@claude-plugins-official" = true;
    };
    theme = "auto";
    skipDangerousModePermissionPrompt = true;
  });
in
{
  home.packages = [
    claudeWrapped
  ];

  # [Defaults Merge]
  # 保留现有用户本地 settings.json（如 API env / hooks），仅补充通用默认项
  home.activation.syncClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    claudeDir="$HOME/.claude"
    target="$claudeDir/settings.json"
    mkdir -p "$claudeDir"

    if [ ! -f "$target" ] || ! ${pkgs.jq}/bin/jq -e . "$target" >/dev/null 2>&1; then
      cp -f --no-preserve=mode "${claudeDefaults}" "$target"
    else
      tmpFile=$(mktemp "$claudeDir/.settings.json.XXXXXX")
      if ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "${claudeDefaults}" "$target" > "$tmpFile"; then
        mv "$tmpFile" "$target"
      else
        rm -f "$tmpFile"
      fi
    fi
  '';
}
