{config, lib, dependencySets, ...}: let
  l = lib // builtins;
  t = l.types;

  # drv-parts specific options, not forwardedto the final deirvation call
  drvPartsOptions = {

    /*
      This allows defining drvs in an encapsulated manner, while maintaining
        the capability to depend on external attributes
    */
    deps = l.mkOption {
      description = ''
        All dependencies of the package. This option should be set by the "outer world" and can be used to inherit attributes from `pkgs` or `inputs` etc.

        By separating the task of retrieving things from the outside world, it is ensured that the dependencies are overridable.
        Nothing will stop users from adding `pkgs` itself as a dependency, but this will make it very hard for the user of the package to override any dependencies, because they'd have to figure out a way to insert their changes into the Nixpkgs fixpoint. By adding specific attributes to `deps` instead, the user has a realistic chance of overriding those dependencies.

        So deps should be specific, but not overly specific. For instance, the caller shouldn't have to know the version of a dependency in order to override it. The name should suffice. (e.g. `nix = nixVersions.nix_2_12` instead of `inherit (nixVersions) nix_2_12`.
      '';
      type = t.submoduleWith {
        # TODO: This could be made stricter by removing the freeformType
        # Maybe add option `strictDeps = true/false` ? ;P
        modules = [{freeformType = t.lazyAttrsOf t.raw;}];
        specialArgs = dependencySets;
      };
      example = lib.literalExpression ''
        {pkgs, inputs', ...}: {
          inherit (pkgs) stdenv;
          inherit (pkgs.haskellPackages) pandoc;
          nix = inputs'.nix.packages.default;
        }
      '';
    };

    env = lib.mkOption {
      type = let
        baseTypes = [t.bool t.int t.str t.path t.package];
        allTypes = baseTypes ++ [(t.listOf (t.oneOf baseTypes))];
      in
        t.attrsOf (t.oneOf allTypes);
      default = {};
    };

  };
in {
  options = drvPartsOptions;
}
