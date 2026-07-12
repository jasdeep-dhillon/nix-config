{
  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io/"
      "https://cache.nixos-cuda.org"
      "https://nix-community.cachix.org/"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
    experimental-features = [
      "cgroups"
      "flakes"
      "nix-command"
      "pipe-operators"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
    http-connections = 50;
    show-trace = true;
    use-cgroups = true;
    use-xdg-base-directories = true;
    warn-dirty = false;
    allow-unfree = true;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    home-manager.url = "github:nix-community/home-manager";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/001e560fffc8f0235e9db20ebeb4ccde0ade1caf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    run0-sudo-shim = {
      url = "github:lordgrimmauld/run0-sudo-shim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:Jasdeep-Dhillon/helium-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vibepanel = {
      url = "github:prankstr/vibepanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # dms = {
    #   url = "github:AvengeMedia/DankMaterialShell/stable";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # dms-plugin-registry = {
    #   url = "github:AvengeMedia/dms-plugin-registry";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    hypridle.url = "github:hyprwm/hypridle";
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      inherit (lib.fileset) toList fileFilter;
      isNix = file: file.hasExt "nix" && file.name != "flake.nix" && !lib.hasPrefix "_" file.name;
      importTree = path: toList (fileFilter isNix path);
      mkFlake = inputs.flake-parts.lib.mkFlake { inherit inputs; };
    in
    mkFlake { imports = importTree ./.; };

}
