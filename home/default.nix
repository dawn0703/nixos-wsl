# ---
# Module: Home Switchboard
# Description: Unified entry point for Home Manager user modules in NixOS-WSL
# Scope: Home Manager
# ---

{ lib, profile, ... }: {
  imports = [
    ./shell
    ./cli
    ./dev
    ./harness
    ./editor
  ];

  home = {
    username = profile.username;
    homeDirectory = "/home/${profile.username}";
    stateVersion = "24.11";
  };

  # [WSL Drives]
  # 在家目录提供指向 D 盘及常用目录的快捷软链接，方便终端与 Agent 直接访问
  home.activation.ensureWslDriveLinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d /mnt/d ]; then
      if [ -L "$HOME/D" ] || [ ! -e "$HOME/D" ]; then
        ln -sfn /mnt/d "$HOME/D"
      fi
      for dir in Research Projects Study; do
        if [ -d "/mnt/d/$dir" ] && { [ -L "$HOME/$dir" ] || [ ! -e "$HOME/$dir" ]; }; then
          ln -sfn "/mnt/d/$dir" "$HOME/$dir"
        fi
      done
    fi
  '';

  programs.home-manager.enable = true;
}
