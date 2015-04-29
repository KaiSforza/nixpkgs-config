{
  packageOverrides = pkgs:
  # For version declarations and such
  let
    vimV = {
      name = "vim-python3";
      majVer = "7";
      minVer = "4";
      patch = "712";
    };
    # For package building from custom files.
    callPackage = (extra: pkgs.stdenv.lib.callPackageWith (pkgs // pkgs.xorg)) {};
    recurseIntoAttrs = attrs: attrs // { recurseForDerivations = true; };

  # Main changes
  in rec {
    # Build hub from git
    hub-kaictl = pkgs.stdenv.lib.overrideDerivation pkgs.gitAndTools.hub (oldAttrs: {
      name = "hubUnstable";
      src = pkgs.fetchgit {
        url = "http://github.com/github/hub";
        rev = "64187e3cb84c6956826acad2803958730a7ea180";
        sha256 = "0s797d9gjbj0rh9lgi4dkc3kpibbih0y2fv92h8q3ai7q54gx84q";
      };
    });

    macvim-kaictl = pkgs.stdenv.lib.overrideDerivation pkgs.macvim (oldAttrs: {
      name = "macvim-7.4.648";
      src = pkgs.fetchgit {
        url = "http://github.com/genoma/macvim";
        rev = "408cf6d87102ef68c15ef32c35c10826467c22bd";
        sha256 = "0yp7y981smnq1fipg3dx2k0d3gw8vv4kdy8152xvdbd7v4lja9nl";
      };
    });

    vim-python3 = pkgs.stdenv.lib.overrideDerivation 
      (pkgs.vim_configurable_nogui.override {
        config.vim = {
          python = true;
          lua = true;
          multibyte = true;
          ruby = false;
          gui = false;
        };
        python = python34-kaictl;
        lua = pkgs.lua;
      })
      (oldAttrs: {
      name = "vim-python3-${vimV.majVer}.${vimV.minVer}.${vimV.patch}";
      src = pkgs.fetchgit {
        url = "http://github.com/vim/vim";
        # url = "http://github.com/vim-jp/vim";
        rev = "refs/tags/v${vimV.majVer}-${vimV.minVer}-${vimV.patch}";
        # sha256 = "0irp4cd6hcgzz3w5fjxvqvlfclayi2wg67h3y6y517y9l08pslnw";
        sha256 = "00kv5fvhsdvpcnf8ca9xs3gz3fr8jvnb8r5znwwadxhv73gzlf01";
        # sha256 = "0irp4cd6hcgzz3w5fjxvqvlfclayi2wg67h3y6y517y9l08pslnw";
      };
    });

    #######################################################################
    ###                          Custom Packages                        ###
    #######################################################################
    # Custom python 3 package.
    python34-kaictl = pkgs.stdenv.lib.hiPrio (
      callPackage /nix/nixpkgs/pkgs/development/interpreters/python/3.4 {
        libX11 = null;
        xproto = null;
        tcl = null;
        tk = null;
        self = pkgs.python34;
      }
    );
    # Sets up python34 packages to be built against my python34-kaictl
    python34Packages-kaictl = recurseIntoAttrs (callPackage /nix/nixpkgs/pkgs/top-level/python-packages.nix {
      python = python34-kaictl;
      self = python34Packages-kaictl;
    });
    # builds ipython3 without a bunch of gui stuff.
    ipython3 = callPackage /nix/nixpkgs/pkgs/shells/ipython {
      buildPythonPackage = python34Packages-kaictl.buildPythonPackage;
      pythonPackages = python34Packages-kaictl;
      pyqt4 = false;
      notebookSupport = false;
      qtconsoleSupport = false;
      pylabSupport = false;
      pylabQtSupport = false;
    };

  };
  allowUnfree = true;
}
