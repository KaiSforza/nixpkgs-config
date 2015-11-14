let
  pkgs = import <nixpkgs> {};
in
pkgs.stdenv.mkDerivation {
  name = "haskell-nix";
  version = "0.3.0.0";
  src = ./.;
  buildInputs = [ (pkgs.haskell.packages.ghcHEAD.ghcWithPackages 
    (hs: with hs; [
      ghc
      # scientific
      # hoogle
      ]
    )) 
    # For :edit
    pkgs.vim-python3
    pkgs.ctags
  ];
}
