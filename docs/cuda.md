https://discourse.nixos.org/t/cuda-cache-for-nix-community/56038

```nix
{
  nixpkgs.config.cudaSupport = true;

  nixpkgs.config.allowUnfreePredicate =
    p:
    builtins.all (
      license:
      license.free
      || builtins.elem license.shortName [
        "CUDA EULA"
        "cuDNN EULA"
        "cuTENSOR EULA"
        "NVidia OptiX EULA"
      ]
    ) (if builtins.isList p.meta.license then p.meta.license else [ p.meta.license ]);
}
```

[#cuda:nixos.org matrix room](https://app.element.io/#/room/#cuda:nixos.org)

[Nixpkgs CUDA team](https://nixos.org/community/teams/cuda/)

[package-sets](./package-sets.md)

[cache](./cache.md)
