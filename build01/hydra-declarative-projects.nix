{ lib, pkgs, config, ... }:

{
  services.hydra.declarativeProjects = {
    emacs-overlay = {
      displayName = "Emacs Overlay";
      inputValue = "https://github.com/nix-community/emacs-overlay";
      specFile = "hydra/spec.json";
      description = "Bleeding edge emacs overlay";
      homepage = "https://github.com/nix-community/emacs-overlay";
    };
    simple-nixos-mailserver = {
      displayName = "Simple NixOS MailServer";
      inputValue = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver";
      specFile = ".hydra/spec.json";
      description = "A complete and Simple Nixos Mailserver";
      homepage = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver";
    };
    redoxpkgs = {
      displayName = "Redoxpkgs";
      inputValue = "https://github.com/nix-community/redoxpkgs";
      specFile = ".hydra/spec.json";
      description = "Packages for Redox";
      homepage = "https://github.com/nix-community/redoxpkgs";
    };
  };
}
