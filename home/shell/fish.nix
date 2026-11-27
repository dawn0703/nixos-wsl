# ---
# Module: Fish Shell
# Description: Interactive fish configuration with vi bindings, plugins, and nh/git abbreviations
# Scope: Home Manager
# ---

{ pkgs, profile, ... }: {
  programs.fish = {
    enable = true;

    plugins = [
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
      { name = "colored-man-pages"; src = pkgs.fishPlugins.colored-man-pages.src; }
    ];

    interactiveShellInit = ''
      set -g fish_greeting
      fish_vi_key_bindings

      set -gx NH_ROM 1
      set -gx NH_FLAKE /home/${profile.username}/.dotfiles

      bind -M insert jk "set fish_bind_mode default; commandline -f backward-char force-repaint"
    '';

    shellAbbrs = {
      # [Git]
      gst = "git status";
      gss = "git status --short";
      ga  = "git add";
      gaa = "git add -A";
      gcm = "git commit -m";
      gd  = "git diff";
      gds = "git diff --staged";
      gsw = "git switch";
      gpl = "git pull --ff-only";
      gps = "git push";
      gl  = "git log --oneline --graph --decorate";

      # [NH & Nix]
      nrs    = "nh os switch -H wsl";
      nrb    = "nh os boot -H wsl";
      nclean = "nh clean all --keep 3";
      ns     = "nix search nixpkgs";

      # [Harness]
      hd  = "herdr";
      hdl = "herdr list";
      hda = "herdr attach";

      # [Zellij]
      zj  = "zellij";
      zn  = "zellij --new-session-with-layout";
      za  = "zellij attach";
      zl  = "zellij list-sessions";
      zk  = "zellij kill-session";

      # [WSL Drives]
      cdd = "cd /mnt/d";
      cdr = "cd /mnt/d/Research";
      cdp = "cd /mnt/d/Projects";
      cds = "cd /mnt/d/Study";
    };
  };
}
