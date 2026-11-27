# ---
# Module: Antigravity Tools
# Description: Antigravity multi-account manager and switcher (CLI + GUI)
# Scope: Home Manager
# Notes:
# - 上游首次运行会把 ~/.local/bin/{at,antigravity-tools} 指向未包装二进制，
#   这里用 home.file 覆盖为转发到包装版的脚本以确保 NixOS 上可正常执行。
# ---

{ lib, pkgs, ... }:
let
  antigravity-tools = pkgs.callPackage ./package.nix { };
in
{
  home.packages = [ antigravity-tools ];

  home.sessionPath = [ "$HOME/.local/bin" ];

  # [WSL Keyring]
  # WSL 无桌面登录解锁流程时初始化默认无锁 keyring，防止 secret-tool 卡在解锁弹窗
  home.activation.ensureWslKeyring = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    keyringDir="$HOME/.local/share/keyrings"
    mkdir -p "$keyringDir"
    chmod 700 "$keyringDir"

    if [ ! -e "$keyringDir/default" ] && [ ! -e "$keyringDir/login.keyring" ]; then
      printf 'Default_keyring' > "$keyringDir/default"
      chmod 600 "$keyringDir/default"

      if [ ! -e "$keyringDir/Default_keyring.keyring" ]; then
        cat > "$keyringDir/Default_keyring.keyring" <<'EOF'
[keyring]
display-name=Default keyring
ctime=0
mtime=0
lock-on-idle=false
lock-after=false
EOF
        chmod 600 "$keyringDir/Default_keyring.keyring"
      fi
    fi
  '';

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
