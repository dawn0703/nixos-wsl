# ---
# Module: Nix & NH Maintenance
# Description: Flake settings, domestic substituters, nh helper, and garbage collection
# Scope: System
# ---

{ profile, ... }: {
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" profile.username ];
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
    };
  };

  # [NH]
  # 统一的系统更新与旧代清理前端
  programs.nh = {
    enable = true;
    flake = "/home/${profile.username}/.dotfiles";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
  };
}
