# ---
# Module: Herdr Runtime
# Description: Agent-native terminal multiplexer runtime, CLI config, and Windows Herdr asset sync
# Scope: Home Manager
# ---

{ lib, pkgs, profile, ... }:
let
  winUser = profile.windowsUsername or profile.username;
in
{
  home.packages = [
    pkgs.herdr
    pkgs.herdr-core
  ];

  xdg.configFile."herdr/config.toml".text = ''
    onboarding = false

    [ui]
    status_indicators = "dots"
  '';

  # [Windows Sync]
  # 若 Windows 侧已安装原生 Herdr，同步自定义 mod 与布局到宿主机配置目录
  home.activation.syncHerdrWindowsApp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    winHerdrDir="/mnt/c/Users/${winUser}/.config/herdr-app"
    if [ -d "$winHerdrDir" ]; then
      mkdir -p "$winHerdrDir/mods" "$winHerdrDir/layouts"

      ${pkgs.rsync}/bin/rsync -rl --delete --no-perms --no-owner --no-group \
        "${./herdr-assets/mods/skillshare}/" "$winHerdrDir/mods/skillshare/"
      ${pkgs.rsync}/bin/rsync -rl --delete --no-perms --no-owner --no-group \
        "${./herdr-assets/mods/usage-limits}/" "$winHerdrDir/mods/usage-limits/"

      cp -f --no-preserve=mode \
        "${./herdr-assets/layouts/herdr-skillshare.json}" \
        "${./herdr-assets/layouts/herdr-skillshare.png}" \
        "$winHerdrDir/layouts/"

      if [ -f "$winHerdrDir/shared.json" ]; then
        currentLayout=$(${pkgs.jq}/bin/jq -r '.layout // empty' "$winHerdrDir/shared.json" 2>/dev/null || true)
        if [ -z "$currentLayout" ] || [ "$currentLayout" = "main" ]; then
          tmpShared=$(mktemp)
          if ${pkgs.jq}/bin/jq '.layout = "herdr-skillshare"' "$winHerdrDir/shared.json" > "$tmpShared"; then
            mv "$tmpShared" "$winHerdrDir/shared.json"
          else
            rm -f "$tmpShared"
          fi
        fi
      fi
    fi
  '';
}
