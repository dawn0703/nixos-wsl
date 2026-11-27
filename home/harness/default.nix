# ---
# Module: Harness Switchboard
# Description: AI coding agent runtimes, multiplexers, and CLI harnesses
# Scope: Home Manager
# ---

{ ... }: {
  imports = [
    ./herdr.nix
    ./skillshare.nix
    ./claude-code.nix
    ./codex.nix
    ./cursor.nix
    ./pi.nix
    ./agy.nix
    ./antigravity-tools
  ];
}
