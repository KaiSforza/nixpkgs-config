{
  packageOverrides = pkgs: with pkgs;
  # For version declarations and such
  let
    vimV = {
      name = "vim-python3";
      majVer = "7";
      minVer = "4";
      patch = "712";
    };
  # Main changes
  in rec {
    # Build hub from git
    hub-kaictl = stdenv.lib.overrideDerivation gitAndTools.hub (oldAttrs: {
      name = "hubUnstable";
      src = fetchgit {
        url = "http://github.com/github/hub";
        rev = "64187e3cb84c6956826acad2803958730a7ea180";
        sha256 = "0s797d9gjbj0rh9lgi4dkc3kpibbih0y2fv92h8q3ai7q54gx84q";
      };
    });

    macvim-kaictl = stdenv.lib.overrideDerivation macvim (oldAttrs: {
      name = "macvim-7.4.648";
      src = fetchgit {
        url = "http://github.com/genoma/macvim";
        rev = "408cf6d87102ef68c15ef32c35c10826467c22bd";
        sha256 = "0yp7y981smnq1fipg3dx2k0d3gw8vv4kdy8152xvdbd7v4lja9nl";
      };
    });

    vim-python3 = stdenv.lib.overrideDerivation 
      (vim_configurable_nogui.override {
        config.vim = {
          python = true;
          lua = true;
          multibyte = true;
          ruby = false;
          gui = false;
        };
        ruby = ruby;
        lua = lua5_1;
        darwinSupport = stdenv.isDarwin;
        guiSupport = false;
        multibyteSupport = true;
        python = python34-kaictl;
      })
      (oldAttrs: {
      name = "vim-python3-${vimV.majVer}.${vimV.minVer}.${vimV.patch}";
      src = fetchgit {
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
    python2-kaictl = python2.override {
      x11Support = false;
      tcl = null; tk = null; x11 = null; libX11 = null;
    };
    python2Packages-kaictl = python2Packages.override {
      python = python2-kaictl;
      self = python2Packages-kaictl;
    };
    python3-kaictl = python3.override {
      tcl = null; tk = null; libX11 = null; xproto = null;
    };
    python3Packages-kaictl = python3Packages.override {
      python = python3-kaictl;
      self = python3Packages-kaictl;
    };

    # builds ipython3 without a bunch of gui stuff.
    ipython3 = python3Packages-kaictl.ipython.override {
      pyqt4 = false;
      notebookSupport = false;
      qtconsoleSupport = false;
      pylabSupport = false;
      pylabQtSupport = false;
    };

    weechat-kaictl =
      let ourPythonPackages = python3Packages-kaictl;
          ourPython = ourPythonPackages.python;
      in stdenv.lib.overrideDerivation (
      pkgs.weechat.override {
        python = ourPython;
        pythonPackages = ourPythonPackages;
        guile = null;
        tcl = null;
        lua5 = null;
        ruby = null;
      }
    ) (
      oldAttrs: {
        src = fetchgit {
          url = "https://github.com/weechat/weechat";
          rev = "f026ba51605915772b1aef6fad20ef4f5ce39d02";
          sha256 = "c3eff3b4358a2014504479ff0c42abb9d7c4d950f46d912e060835616686ae41";
        };
        postInstall = null;
        patches = stdenv.lib.optional (ourPython ? isPy3) ./weechat-python.diff;
        cmakeFlags = ["-DENABLE_PYTHON=ON"
                      "-DPYTHON_EXECUTABLE=${ourPython}/bin/${ourPython.executable}"
                      "-DPYTHON_LIBRARY=${ourPython}/lib/lib${ourPython.libPrefix}${
                        if ourPython ? isPy3 then "m"
                                             else ""}.${
                        if stdenv.isDarwin then "dylib"
                                           else "so"}"
                      "-DENABLE_GUILE=OFF"
                      "-DENABLE_TCL=OFF"
                      "-DENABLE_LUA=OFF"
                      "-DENABLE_JAVASCRIPT=OFF"
                      "-DENABLE_RUBY=OFF"
                      ] ++ stdenv.lib.optional (ourPython ? isPy3) "-DENABLE_PYTHON3=ON";
    });
  };
  allowUnfree = true;
}
