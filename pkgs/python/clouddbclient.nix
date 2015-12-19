{stdenv, pythonPackages, fetchgit, git, supernova, troveclient}:

with pythonPackages;
buildPythonPackage rec {
  name = "clouddbClient";
  src = ./clouddbclient;
  buildInputs = [ git pbr ];
  # These are dependencies that will need to be called when the application
  # runs
  doCheck = false;
  propagatedBuildInputs = [ python
                            requests2
                            Babel
                            six
                            supernova
                            troveclient ];
}
