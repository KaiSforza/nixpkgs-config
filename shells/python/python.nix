let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
in rec
{
  # Base python definition
  basePython = { pythonPackages, extraPkgs ? [] }: stdenv.mkDerivation {
    name = pythonPackages.python.name;
    buildInputs = with pythonPackages; [
      python
      requests2
      ipython
    ] ++ extraPkgs;
  };

  # Normal python shells
  python35 = basePython { pythonPackages = py35; };
  python34 = basePython { pythonPackages = py34; };
  python33 = basePython { pythonPackages = py33; };
  python27 = basePython { pythonPackages = py27; };
  
  # Special environments
  datastores =
    let
      p = py34;
    in basePython {
    pythonPackages = p;
    extraPkgs = [
      (hammercloud.override   { pythonPackages = p; })
      (supernova.override     { pythonPackages = p; })
      (clouddbClient.override { pythonPackages = p; })
    ];
  };

  ### packages
  supernova = pkgs.callPackage ../../pkgs/python/supernova.nix {
    pythonPackages = py3;
    git = pkgs.gitMinimal;
  };
  troveclient = pkgs.callPackage ../../pkgs/python/troveclient.nix {
    pythonPackages = py3;
    git = pkgs.gitMinimal; 
  };
  hammercloud = pkgs.callPackage ../../pkgs/python/hammercloud.nix {
    pythonPackages = py3;
  };
  clouddbClient = pkgs.callPackage ../../pkgs/python/clouddbclient.nix {
    pythonPackages = py3;
    git = pkgs.gitMinimal; 
    supernova = supernova;
  };

  # Aliases and shortenings
  py35 = pkgs.python3Packages-kaictl;
  py34 = pkgs.python34Packages-kaictl;
  py33 = pkgs.python33Packages-kaictl;
  py27 = pkgs.python2Packages-kaictl;
  py3 = py34;
  py2 = py27;
  python3 = python34;
  python2 = python27;
}
