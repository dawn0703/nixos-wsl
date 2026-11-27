# ---
# Module: Skillshare CLI
# Description: Skillshare CLI for syncing skills, agents, MCP, and plugins across AI CLIs
# Scope: Home Manager
# ---

{ lib, pkgs, ... }:
let
  skillshareCli = pkgs.stdenv.mkDerivation rec {
    pname = "skillshare";
    version = "0.31.0";

    src = pkgs.fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_linux_amd64.tar.gz";
      hash = "sha256-opQ9Xf7uwLYmpxxxDS/B27+sVWOG/bjPS4svRIXoN8A=";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 skillshare "$out/bin/skillshare"
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Sync skills, agents, MCP, and plugins to AI CLI tools";
      homepage = "https://github.com/runkids/skillshare";
      license = licenses.mit;
      platforms = [ "x86_64-linux" ];
      mainProgram = "skillshare";
    };
  };
in {
  home.packages = [ skillshareCli ];

  # [Init]
  # 首次激活时自动初始化 skillshare 配置目录，避免 Herdr skillshare 面板报错
  home.activation.ensureSkillshareInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.config/skillshare/config.yaml" ]; then
      ${skillshareCli}/bin/skillshare init --no-copy --all-targets --no-git --no-skill || true
    fi
  '';
}
