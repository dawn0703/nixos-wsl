# ---
# Module: Secret Service Keyring
# Description: GNOME Keyring and libsecret for headless WSL credential storage (at/agy)
# Scope: System
# ---

{ pkgs, ... }: {
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    libsecret
  ];
}
