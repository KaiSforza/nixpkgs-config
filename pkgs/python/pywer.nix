{stdenv, pythonPackages, fetchgit}:

with pythonPackages;
buildPythonPackage rec {
  name = "pywer-0.13";
  # src = /path/to/repo
  src = fetchgit {
    url = "https://github.com/KaiSforza/pywer";
    rev = "64aef650b00b5a622be0346b266774a2db7d1c03";
    sha256 = "1026c0cb3b5eabb23c42fe10a5c5dfcbd233e534382955b0721c535ac9d6c9c5";
  };
  # These are dependencies that will need to be called when the application
  # runs 
  propagatedBuildInputs = [ python requests2 pyxdg ];
}
