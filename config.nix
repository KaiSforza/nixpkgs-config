{
  packageOverrides = pkgs: with pkgs;
  # For version declarations and such
  let
    vimV = {
      name = "vim-python3";
      majVer = "7";
      minVer = "4";
      patch = "729";
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

    macvim-kaictl = stdenv.lib.overrideDerivation (
      macvim.override {
        ruby = null;
      }
      ) (
        oldAttrs: {
        name = "macvim-7.4.648";
        buildInputs = [
          gettext ncurses pkgconfig luajit tcl perl python
        ];
        configureFlags = [
            #"--enable-cscope" # TODO: cscope doesn't build on Darwin yet
            "--enable-fail-if-missing"
            "--with-features=huge"
            "--enable-gui=macvim"
            "--enable-multibyte"
            "--enable-nls"
            "--enable-luainterp=dynamic"
            "--enable-pythoninterp=dynamic"
            "--enable-perlinterp=dynamic"
            "--enable-rubyinterp=no"
            "--enable-tclinterp=yes"
            "--without-local-dir"
            "--with-luajit"
            "--with-lua-prefix=${luajit}"
            "--with-tclsh=${tcl}/bin/tclsh"
            "--with-tlib=ncurses"
            "--with-compiledby=Nix"
        ];
        src = fetchgit {
          url = "http://github.com/genoma/macvim";
          rev = "408cf6d87102ef68c15ef32c35c10826467c22bd";
          sha256 = "0yp7y981smnq1fipg3dx2k0d3gw8vv4kdy8152xvdbd7v4lja9nl";
        };
        postInstall = ''
          mkdir -p $out/Applications
          cp -r src/MacVim/build/Release/MacVim.app $out/Applications

          rm $out/bin/{Vimdiff,Vimtutor,Vim,ex,rVim,rview,view}

          cp src/MacVim/mvim $out/bin
          cp src/vimtutor $out/bin

          for prog in "vimdiff" "vi" "vim" "ex" "rvim" "rview" "view"; do
            ln -s $out/bin/mvim $out/bin/$prog
          done

          # Fix rpaths
          exe="$out/Applications/MacVim.app/Contents/MacOS/Vim"
          libperl=$(dirname $(find ${perl} -name "libperl.dylib"))
          install_name_tool -add_rpath ${luajit}/lib $exe
          install_name_tool -add_rpath ${tcl}/lib $exe
          install_name_tool -add_rpath ${python}/lib $exe
          install_name_tool -add_rpath $libperl $exe
        '';
      }
    );

    vim-python3 = stdenv.lib.overrideDerivation
      (vim_configurable.override {
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
        gui = "no";
        multibyteSupport = true;
        python = python3-kaictl;
      })
      (oldAttrs: {
      name = "vim-python3-${vimV.majVer}.${vimV.minVer}.${vimV.patch}";
      src = fetchgit {
        url = "http://github.com/vim/vim";
        rev = "refs/tags/v${vimV.majVer}-${vimV.minVer}-${vimV.patch}";
        # sha256 = "03b7cb966e9fe97ae2bb6d7e1e0ec2265aa28228c6a83842bb5274d100788849";
        sha256 = "564de68e69ae1476d886b0781d98b3fb497c65ac2ece3248bad04b096f7d8113";
      };
    });

    vim-python2 = stdenv.lib.overrideDerivation
      (vim_configurable.override {
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
        gui = "no";
        multibyteSupport = true;
        python = python2-kaictl;
      })
      (oldAttrs: {
      name = "vim-python2-${vimV.majVer}.${vimV.minVer}.${vimV.patch}";
      src = fetchgit {
        url = "http://github.com/vim/vim";
        rev = "refs/tags/v${vimV.majVer}-${vimV.minVer}-${vimV.patch}";
        # sha256 = "03b7cb966e9fe97ae2bb6d7e1e0ec2265aa28228c6a83842bb5274d100788849";
        sha256 = "564de68e69ae1476d886b0781d98b3fb497c65ac2ece3248bad04b096f7d8113";
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

    git-kaictl = git.override {
      pythonSupport = false;
      # python = python2-kaictl;
      svnSupport = false;
      guiSupport = false;
      sendEmailSupport = false;	# requires plenty of perl libraries
    };

    all = buildEnv {
      name = "all";
      paths = [
        vim-python3
        ipython3
        coreutils
        file
        findutils
        git-kaictl
        gnused
        less
        # macvim
        openssh
        python3-kaictl
        rsync
        tmux
        tree
        weechat-kaictl
        zsh
        curl
        nix-repl
      ];
    };
  };
  allowUnfree = true;
}
