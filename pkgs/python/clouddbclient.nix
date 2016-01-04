{stdenv, pythonPackages, fetchgit, git, supernova}:

with pythonPackages;
buildPythonPackage rec {
  name = "clouddbClient";
  src = ./clouddbclient;
  buildInputs = [ git pbr ];
  # These are dependencies that will need to be called when the application
  # runs
  propagatedBuildInputs = [ python
                            requests2
                            Babel
                            six
                            supernova
                            ];
}
