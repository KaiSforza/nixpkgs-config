{stdenv, pythonPackages, fetchurl, git}:

with pythonPackages;
buildPythonPackage rec {
  name = "troveclient-1.4.0";
  src = fetchurl {
    url = "https://pypi.python.org/packages/source/p/python-troveclient/python-troveclient-1.4.0.tar.gz";
    sha256 = "0l9bkkx9qrax6qyvr47rcy1qxl5n6acxb41ji1dy6v2hidmqs34r";
  };
  # buildInputs = [ pbr ];
  # These are dependencies that will need to be called when the application
  # runs
  doCheck = false;
  propagatedBuildInputs = [ python
                            requests2
                            Babel
                            six
                            keystoneclient
                            oslo-utils
                            simplejson
                            prettytable
                            # httplib2
                            # testtools
                            # testscenarios
                            # testrepository
                            # requests-mock
                            ];
}
