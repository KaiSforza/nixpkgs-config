{stdenv, pythonPackages, fetchurl, git}:

with pythonPackages;
buildPythonPackage rec {
  name = "troveclient-1.4.0";
  src = fetchurl {
    url = "https://pypi.python.org/packages/source/p/python-troveclient/python-troveclient-1.4.0.tar.gz";
    sha256 = "0l9bkkx9qrax6qyvr47rcy1qxl5n6acxb41ji1dy6v2hidmqs34r";
  };
  buildInputs = [ python
                  httplib2
                  testtools
                  testscenarios
                  testrepository
                  requests-mock
                ];
  # Fixes up the tests. Four of them fail when doing mock http requests,
  # those are skipped.
  prePatch = ''
    substituteInPlace .testr.conf \
      --replace 'python' '${pythonPackages.python.interpreter}'
    substituteInPlace troveclient/tests/test_shell.py \
      --replace "expected = '\\n'.join([" "return True ; (["
  '';
  # These are dependencies that will need to be called when the application
  # runs
  propagatedBuildInputs = [ python
                            requests2
                            Babel
                            six
                            keystoneclient
                            oslo-utils
                            simplejson
                            prettytable
                            ];
}
