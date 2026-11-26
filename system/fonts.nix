# ---
# Module: Typography
# Description: Open-source WSL fonts and fontconfig defaults
# Scope: System
# ---

{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      maple-mono.NF-CN
      inter
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
        autohint = false;
      };
      defaultFonts = {
        sansSerif = [ "Inter" "Noto Sans CJK SC" ];
        serif = [ "Noto Sans CJK SC" ];
        monospace = [ "Maple Mono NF CN" "Noto Sans Mono CJK SC" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
