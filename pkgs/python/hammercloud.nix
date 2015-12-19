let
  pkgs = import <nixpkgs> {};
  pname = "hammercloud";
in

{ stdenv ? pkgs.stdenv
, pythonPackages ? pkgs.python3Packages
, git ? pkgs.gitMinimal
}:

with pythonPackages;
buildPythonPackage rec {
  name = pname;
  src = ./hammercloud;
  buildInputs = [git pbr];
  # These are dependencies that will need to be called by the application
  # when it runs
  propagatedBuildInputs = [ python
                            requests2
                            pexpect
                            pythonPackages.readline
                            pkgs.expect
                          ];
}
