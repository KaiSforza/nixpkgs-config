Custom Packages for Nixos
=========================

This is a collection of my custom packages for Nix. This requires a working
nixpkgs repo or channel. To use this, clone it to your ~/.nixpkgs directory,
or copy the bits you want into there.

Basic usage::

    $ nix-env -qaP -f ~/.nixpkgs/shells -A python
    python.python2        python-2.7.11
    python.python33       python3-3.3.6
    python.datastores     python3-3.4.3
    python.python3        python3-3.4.3
    python.python35       python3-3.5.1
    python.clouddbClient  python3.4-clouddbClient
    python.hammercloud    python3.4-hammercloud
    python.supernova      python3.4-supernova-2.2.0
    python.troveclient    python3.4-troveclient-1.4.0

    $ nix-shell ~/.nixpkgs/shells -A python.python34

    [nix-shell:~]$ type python3
    python3 is /nix/store/gq6vh2b7hyksg7zakdlhgrhpcld38wnh-python3-3.4.3/bin/python3

There are also some other packages included in there under:

* Python
* Ruby
* Haksell

Though most of them are in the python. attribute.
