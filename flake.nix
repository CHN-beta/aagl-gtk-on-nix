{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = {nixpkgs, ...}: let
    inherit (nixpkgs) lib;
    genSystems = lib.genAttrs [
      # Supported OSes
      "x86_64-linux"
    ];

    nixpkgs-nonfree = import nixpkgs {
      system = "x86_64-linux";
      config = { allowUnfree = true; };
    };

    an-anime-game-launcher-unwrapped = pkgs: pkgs.callPackage ./pkgs/an-anime-game-launcher/unwrapped.nix {};
    an-anime-game-launcher = pkgs: pkgs.callPackage ./pkgs/an-anime-game-launcher/default.nix {
      an-anime-game-launcher-unwrapped = an-anime-game-launcher-unwrapped pkgs;
    };

    the-honkers-railway-launcher = pkgs: pkgs.callPackage ./pkgs/the-honkers-railway-launcher {
      the-honkers-railway-launcher-unwrapped = the-honkers-railway-launcher-unwrapped pkgs;
    };

    the-honkers-railway-launcher-unwrapped = pkgs: pkgs.callPackage ./pkgs/the-honkers-railway-launcher/unwrapped.nix {};

    honkers-launcher = pkgs: pkgs.callPackage ./pkgs/honkers-launcher/default.nix {
      honkers-launcher-unwrapped = honkers-launcher-unwrapped pkgs;
    };

    honkers-launcher-unwrapped = pkgs: pkgs.callPackage ./pkgs/honkers-launcher/unwrapped.nix {};

    unwrapped = an-anime-game-launcher-unwrapped;
    regular = an-anime-game-launcher;
  in {
    nixosModules.default = import ./module/default.nix;
    nixConfig = {
      extra-substituters = ["https://ezkea.cachix.org"];
      extra-trusted-public-keys = ["ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="];
    };
    packages = genSystems (system: {
      unwrapped = unwrapped nixpkgs-nonfree;
      default = regular nixpkgs-nonfree;

      an-anime-game-launcher-unwrapped = unwrapped nixpkgs-nonfree;
      an-anime-game-launcher = regular nixpkgs-nonfree;

      the-honkers-railway-launcher-unwrapped = the-honkers-railway-launcher-unwrapped nixpkgs-nonfree;
      the-honkers-railway-launcher = the-honkers-railway-launcher nixpkgs-nonfree;

      honkers-launcher = honkers-launcher nixpkgs-nonfree;
      honkers-launcher-unwrapped = honkers-launcher-unwrapped nixpkgs-nonfree;
    });
    overlays.default = _: prev: {
      an-anime-game-launcher-unwrapped = unwrapped prev;
      an-anime-game-launcher = regular prev;

      the-honkers-railway-launcher-unwrapped = the-honkers-railway-launcher-unwrapped prev;
      the-honkers-railway-launcher = the-honkers-railway-launcher prev;

      honkers-launcher = honkers-launcher prev;
      honkers-launcher-unwrapped = honkers-launcher-unwrapped prev;
    };
  };
}
