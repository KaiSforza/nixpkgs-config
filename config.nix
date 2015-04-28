{
  packageOverrides = pkgs:
    # For version declarations and such
    let 
      ipythonVersion = builtins.parseDrvName pkgs.python34Packages.ipython.name;
      vimV = {
        name = "vim-python3";
        majVer = "7";
        minVer = "4";
        patch = "712";
      };
      callPackage = (extra: pkgs.stdenv.lib.callPackageWith (pkgs // pkgs.xorg)) {};

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

    # Custom python 3 package.
    python34-kaictl = pkgs.stdenv.lib.hiPrio (
      callPackage ./pkgs/python/3.4/python34.nix {
        self = pkgs.python34;
      }
    );

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
      src = pkgs.fetchhg {
        url = "http://vim.googlecode.com/hg/";
        rev = "v${vimV.majVer}-${vimV.minVer}-${vimV.patch}";
      };
    });

    ipython3 = with pkgs; buildEnv {
      name = "ipython3-" + ipythonVersion.version;
      paths = [ pkgs.python34Packages.ipython ];
    };
  };
  allowUnfree = true;
}
