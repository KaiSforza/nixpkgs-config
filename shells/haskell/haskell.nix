let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
in
{
  haskellNix = stdenv.mkDerivation {
    name = "haskellNix";
    version = "0.3.0.0";
    buildInputs = [ (pkgs.haskell.packages.ghc7102.ghcWithPackages 
      (hs: with hs; [ ghc ])) 
      pkgs.vim-python3
      pkgs.ctags
    ];
  };
  haskellNixHEAD = stdenv.mkDerivation {
    name = "haskellNixHEAD";
    version = "0.3.0.0";
    buildInputs = [ (pkgs.haskell.packages.ghcHEAD.ghcWithPackages 
      (hs: with hs; [ ghc ])) 
      pkgs.vim-python3
      pkgs.ctags
    ];
  };
  hoogle = pkgs.stdenv.mkDerivation {
    name = "hoogleNix";
    version = "0.1.0.0";
    buildInputs = [ (pkgs.haskell.packages.ghc7102.ghcWithPackages 
      (hs: with hs; [ hoogle ])) 
    ];
  };
}
