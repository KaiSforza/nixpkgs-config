let
  pkgs = import <nixpkgs> {};
in
{ stdenv ? pkgs.stdenv,
  python ? pkgs.python2,
  pythonRequests ? pkgs.python2Packages.requests,
  ipython ? pkgs.python2Packages.ipython }:

stdenv.mkDerivation {
  name = "python-nix";
  version = "0.1.0.0";
  src = ./.;
  buildInputs = [ python pythonRequests ipython ];
}

