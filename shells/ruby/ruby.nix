let
  pkgs = import <nixpkgs> {};
in rec
{
  rubyNix = pkgs.stdenv.mkDerivation rec {
    name = "ruby-nix";
    version = "0.1.0.0";
    buildInputs = with pkgs; [
      ruby
    ];
  };
}
