{stdenv, pythonPackages, fetchgit, git}:

with pythonPackages;
buildPythonPackage rec {
  name = "supernova-2.2.0";
  # src = /path/to/repo
  src = fetchgit {
    url = "https://github.com/major/supernova";
    rev = "refs/tags/v2.2.0";
    sha256 = "0ddgb1gk9mcyk6h3l10xzv4fz8hgx768apb02iw3vjwjkg9m26bv";
  };
  buildInputs = [ git pbr ];
  # These are dependencies that will need to be called when the application
  # runs
  propagatedBuildInputs = [ python
                            requests2
                            pyxdg
                            click
                            configobj
                            keyring
                            novaclient ];
}
