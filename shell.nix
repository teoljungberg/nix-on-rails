with import <nixpkgs> { };

let
  stdenv = pkgs.clangStdenv;

  postgresql = postgresql_13;
  ruby = ruby_3_0;
  paths =
    [ clang git libpcap libxml2 libxslt pkg-config postgresql redis ruby zlib ];

  env = pkgs.buildEnv {
    name = "YOUR_APP_ENV";
    paths = paths;
    extraOutputsToInstall = [ "bin" "dev" "lib" ];
  };

  cpathEnv = builtins.getEnv "CPATH";
  libraryPathEnv = builtins.getEnv "LIBRARY_PATH";
  pathEnv = builtins.getEnv "PATH";
in stdenv.mkDerivation {
  name = "YOUR_APP";

  buildInputs = paths;

  shellHook = ''
    export PGHOST=$(pwd)/tmp/postgres
    export PGDATA=$PGHOST/data
    export PGDATABASE=postgres
    export PGLOG=$PGHOST/postgres.log
    export PGPORT=FILL_IN
    unset CC

    CPATH=${
      pkgs.lib.makeSearchPathOutput "dev" "include" [ libxml2 libxslt ]
    }:${cpathEnv}
    LIBRARY_PATH=${
      pkgs.lib.makeLibraryPath [ libxml2 libxslt ]
    }:${libraryPathEnv}
    PATH=$HOME/.gem/ruby/${ruby.version.libDir}/bin:${
      pkgs.lib.makeBinPath [ env postgresql ]
    }:${pathEnv}
  '';
}
