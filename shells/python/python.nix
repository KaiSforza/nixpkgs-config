let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.clangStdenv;
  # pythonPackages = pkgs.python3Packages-kaictl-clang;

  # Base python definition
  basePython = { pythonPackages, extraPkgs ? [] }: pkgs.clangStdenv.mkDerivation {
    name = pythonPackages.python.name;
    buildInputs = with pythonPackages; [
      python
    ] ++ extraPkgs;
  };
  py35Clang = pkgs.python3Packages-kaictl-clang;
  py35 = pkgs.python3Packages-kaictl;
  py34 = pkgs.python34Packages-kaictl;
  py33 = pkgs.python33Packages-kaictl;
  py27 = pkgs.python2Packages-kaictl-clang;
  py3Clang = py35Clang;
  py3 = py35;
  py2 = py27;
in rec
{
  # Normal python shells
  python3-clang = basePython {
    pythonPackages = py35Clang;
    extraPkgs = with py35Clang; [ requests2 ipython ];
  };
  python35 = basePython {
    pythonPackages = py35;
    extraPkgs = with py35; [ requests2 ipython ];
  };
  python34 = basePython {
    pythonPackages = py34;
    extraPkgs = with py34; [ requests2 ipython ];
  };
  python33 = basePython {
    pythonPackages = py33;
    extraPkgs = with py33; [ requests2 ipython ];
  };
  python27-clang = basePython {
    pythonPackages = py27;
    extraPkgs = with py27; [ requests2 ipython ];
  };
  
  # Special environments
  datastores = basePython {
    pythonPackages = py2;
    extraPkgs = with py2; [
      requests2
      hammercloud
      supernova
      ipython
      clouddbClient
    ];
  };

  ### packages
  supernova = pkgs.callPackage ../../pkgs/python/supernova.nix {
    stdenv = stdenv;
    pythonPackages = py2;
    git = pkgs.gitMinimal;
  };
  # supernova3 = pkgs.callPackage ../../pkgs/python/supernova.nix {
  #   pythonPackages = py3Clang;
  #   git = pkgs.gitMinimal;
  # };

  troveclient = pkgs.callPackage ../../pkgs/python/troveclient.nix {
    stdenv = stdenv;
    pythonPackages = py2;
    git = pkgs.gitMinimal; 
  };

  hammercloud = pkgs.callPackage ../../pkgs/python/hammercloud.nix {
    stdenv = stdenv;
    pythonPackages = py2;
  };
  # hammercloud3 = pkgs.callPackage ../../pkgs/python/hammercloud.nix {
  #   pythonPackages = py3Clang;
  # };

  clouddbClient = pkgs.callPackage ../../pkgs/python/clouddbclient.nix {
    stdenv = stdenv;
    pythonPackages = py2;
    git = pkgs.gitMinimal; 
    supernova = supernova;
    troveclient = troveclient;
  };

  # Aliases
  python3 = python3-clang;
  python27 = python27-clang;
  python2 = python27;
}
