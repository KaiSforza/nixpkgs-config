let
  pkgs = import <nixpkgs> {};
in
# {{{
{
  # Initial definitions {{{
  packageOverrides = pkgs: with pkgs;
  let
    # version declarations {{{
    vimV = {
      name = "vim-python3";
      majVer = "7";
      minVer = "4";
      patch = "922";
      sha = "59c693b13ccd8fdf03e75082059449c016a69e2dac669c16ef8cd24becf74710";
    };
    vimsrc = pkgs.fetchgit {
      url = "http://github.com/vim/vim";
      rev = "refs/tags/v${vimV.majVer}.${vimV.minVer}.${vimV.patch}";
      sha256 = vimV.sha;
    };
    ytdl = {
      ver = "2015.11.13";
      hash = "02140awgwvspnq226xpbc4clijmqkk8hlmfqhmmzzbihvs2b4xfx";
    };
    #}}}
  # }}}

  # Packages {{{
  in rec {
    # {{{ Package Modifications
    #######################################################################
    ###                          Custom Packages                        ###
    #######################################################################
    # {{{ Vims
    _vim-kaictl-base = vim_configurable.override {
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
    };
    # macvim {{{
    macvim-kaictl = stdenv.lib.overrideDerivation (
      macvim.override {
        ruby = null;
      }
      ) (
        oldAttrs: {
          name = "macvim-kaictl-7.4.648";
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
    # }}}

    # Python 3 version {{{
    vim-python3 = stdenv.lib.overrideDerivation
      (_vim-kaictl-base.override { python = python3-kaictl; })
      (oldAttrs: {
        name = "vim-python3-${vimV.majVer}.${vimV.minVer}.${vimV.patch}";
        src = vimsrc;
    });
    # }}}

    # Python 2 version {{{
    python2-kaictl = python2.override {
      x11Support = false;
      tcl = null; tk = null; x11 = null; libX11 = null;
    };
    # }}}
    # }}}

    # Custom python setups {{{
    # Python 2 {{{
    python2Packages-kaictl = python2Packages.override {
      python = python2-kaictl;
      self = python2Packages-kaictl;
    }; # }}}
    # Python 3 {{{
    python3-kaictl = python35.override {
      tcl = null; tk = null; libX11 = null; xproto = null;
    };
    python3Packages-kaictl = python35Packages.override {
      python = python3-kaictl;
      self = python3Packages-kaictl;
    }; # }}}
    # ipython 3 (no gui) {{{
    ipython3 = python3Packages-kaictl.ipython.override {
      pyqt4 = false;
      notebookSupport = false;
      qtconsoleSupport = false;
      pylabSupport = false;
      pylabQtSupport = false;
    }; # }}}
    # }}}

    # Weechat {{{
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
    }); # }}}

    # mvp {{{
    mpv-kaictl = callPackage ./pkgs/mpv {
      lua = lua5_1;
      lua5_sockets = lua5_1_sockets;
      youtubeSupport = true;
      youtube-dl = youtube-dl-kaictl;
      vaapiSupport = true;
      vaapi = vaapiIntel;
    }; # }}}

    # Git {{{
    git-kaictl = git.override {
      pythonSupport = false;
      python = python2-kaictl;
      svnSupport = false;
      guiSupport = false;
      sendEmailSupport = false;	# requires plenty of perl libraries
    }; # }}}

    # Youtube-dl {{{
    youtube-dl-kaictl = stdenv.lib.overrideDerivation
        python3Packages-kaictl.youtube-dl (oldAttrs: {
            name = "youtube-dl-${ytdl.ver}";

            src = fetchurl {
                url = "http://youtube-dl.org/downloads/${ytdl.ver}/youtube-dl-${ytdl.ver}.tar.gz";
                sha256 = ytdl.hash;
            };
        }); # }}}
    # }}}

    # Package lists {{{
    games = buildEnv {
      name = "games";
      paths = [
        firefox
        steam
      ];
    };
    all = buildEnv {
      name = "all";
      ignoreCollisions = true;
      paths = [
        vim-python3
        ctags
        ipython3
        coreutils
        file
        findutils
        gitMinimal
        gnused
        less
        openssh
        python3-kaictl
        rsync
        tmux
        tree
        weechat-kaictl
        aspellDicts.en
        zsh
        curl
        nix-repl
        nix-prefetch-scripts
      ] ++ stdenv.lib.optionals stdenv.isDarwin [ macvim-kaictl ]
        ++ stdenv.lib.optionals stdenv.isLinux [
          i3lock
          lzop
          dmenu
          mpd
          mpc_cli
          vimpc
          mpv-kaictl
          youtube-dl-kaictl
          ncurses
          pamixer
          rxvt_unicode-with-plugins
          unzip
          xorg.xbacklight
          zathura
        ];
    }; # }}}
  }; # }}}
  # Configuration {{{
  allowUnfree = true;
  # }}}
}

# vim: set fdm=marker:
