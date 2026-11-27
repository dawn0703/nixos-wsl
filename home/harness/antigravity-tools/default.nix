# ---
# Module: Antigravity Tools
# Description: Antigravity multi-account manager and switcher (CLI + GUI)
# Scope: Home Manager
# Notes:
# - 上游首次运行会把 ~/.local/bin/{at,antigravity-tools} 指向未包装二进制，
#   这里用 home.file 覆盖为转发到包装版的脚本以确保 NixOS 上可正常执行。
# ---

{ pkgs, ... }:
let
  antigravity-tools = pkgs.callPackage ./package.nix { };
in
{
  home.packages = [ antigravity-tools ];

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.file.".local/bin/at" = {
    text = ''
      #!/bin/sh
      exec ${antigravity-tools}/bin/antigravity-tools "$@"
    '';
    executable = true;
    force = true;
  };

  home.file.".local/bin/antigravity-tools" = {
    text = ''
      #!/bin/sh
      exec ${antigravity-tools}/bin/antigravity-tools "$@"
    '';
    executable = true;
    force = true;
  };
}
