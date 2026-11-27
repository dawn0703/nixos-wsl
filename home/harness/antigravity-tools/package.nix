# ---
# Module: Antigravity Tools Package
# Description: Antigravity multi-account manager packaged from upstream AppImage
# Scope: Home Manager
# Notes:
# - 上游只发布 .deb/.rpm/.AppImage，这里使用 appimageTools.wrapType2 封装。
# - 版本升级时需同步更新 version 与 hash。
# ---

{ pkgs }:
let
  pname = "antigravity-tools";
  version = "5.0.4";

  src = pkgs.fetchurl {
    url = "https://github.com/lbjlaq/Antigravity-Manager/releases/download/v${version}/Antigravity.Tools_${version}_amd64.AppImage";
    hash = "sha256-sKrngQ3T6j2OdQ8qxWHeJWZBsvb2ybNspWjMTr55fDk=";
  };

  extracted = pkgs.appimageTools.extract {
    inherit pname version src;
  };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  # AppImage 缺少此基础依赖库时启动会报错
  extraPkgs = pkgs: [
    pkgs.libgpg-error
  ];

  extraInstallCommands = ''
    install -m 444 -D "${extracted}/Antigravity Tools.desktop" \
      $out/share/applications/antigravity-tools.desktop
    install -m 444 -D "${extracted}/antigravity-tools.png" \
      $out/share/icons/hicolor/512x512/apps/antigravity-tools.png
  '';
}
