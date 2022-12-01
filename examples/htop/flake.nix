{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    drv-parts.url = "nixpkgs";
  };

  outputs = {
    self,
    flake-parts,
    drv-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      systems = ["x86_64-linux"];

      # enable the drv-parts plugin for flake-parts
      imports = [drv-parts.flakeModule];

      perSystem = {config, lib, pkgs, extendModules, ...}: {
        checks = config.packages;

        drvs = {

          # htop defined via submodule
          htop.imports = [./htop.nix];

          # overriding htop
          htop-mod = {
            imports = [./htop.nix];
            pname = lib.mkForce "htop-mod";
            sensorsSupport = false;
          };
        };

        packages = {

          # overriding htop without drv-parts
          htop-mod-nixpkgs =
            (pkgs.htop.overrideAttrs (old: {
              pname = "htop-mod";
            })).override (old: {
              sensorsSupport = true;
            });
        };
      };
    };
}
