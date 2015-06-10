let
  pkgs = import <nixpkgs> {};
  pythonPackages = pkgs.python3Packages-kaictl;

  # Extra package definitions {{{
  pywer = pkgs.callPackage ./pywer.nix { pythonPackages = pythonPackages; };
in
{}:

pkgs.stdenv.mkDerivation rec {
  name = "python3-nix";
  version = "0.1.0.0";
  src = ./.;

  buildInputs = with pythonPackages; [
    python
    requests
    ipython
    pywer
  ];
}
