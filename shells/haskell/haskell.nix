let
  pkgs = import <nixpkgs> {};
in
{}:
pkgs.stdenv.mkDerivation {
  name = "haskell-nix";
  version = "0.1.0.0";
  src = ./.;
  buildInputs = [ (pkgs.haskellPackages.ghcWithPackages 
    (hs: with hs; [
      ghc
      hoogle
      ]
    )) 
  ];
}
