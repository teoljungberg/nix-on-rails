# https://status.nixos.org/
with import
  (fetchTarball "https://github.com/NixOS/nixpkgs/archive/ea7d4aa9b822.tar.gz")
  { };

let
  postgresql = pkgs.postgresql_13;
  ruby = pkgs.ruby_3_0;
  paths = with pkgs; [
    cmake
    file
    gcc
    git
    gnumake
    libffi
    libpcap
    libxml2
    libxslt
    pkg-config
    pkgconfig
    postgresql
    redis
    ruby
    zlib
  ];

  env = pkgs.buildEnv {
    name = "YOUR_APP_ENV";
    paths = paths;
    extraOutputsToInstall = [ "bin" "dev" "lib" ];
  };

  cpathEnv = builtins.getEnv "CPATH";
  libraryPathEnv = builtins.getEnv "LIBRARY_PATH";
  pathEnv = builtins.getEnv "PATH";
in pkgs.mkShell {
  name = "YOUR_APP";
  phases = lib.optional stdenv.isLinux [ "unpackPhase" ] ++ [ "noPhase" ];
  noPhase = "mkdir -p $out";

  buildInputs = paths;

  shellHook = ''
    export PGHOST=$(pwd)/tmp/postgres
    export PGDATA=$PGHOST/data
    export PGDATABASE=postgres
    export PGLOG=$PGHOST/postgres.log
    export PGPORT=FILL_IN
    unset CC

    CPATH=${
      pkgs.lib.makeSearchPathOutput "dev" "include" [
        pkgs.libxml2
        pkgs.libxslt
      ]
    }:${cpathEnv}

    LIBRARY_PATH=${
      pkgs.lib.makeLibraryPath [ pkgs.libxml2 pkgs.libxslt ]
    }:${libraryPathEnv}

    PATH=$HOME/.gem/ruby/${ruby.version}/bin:${
      pkgs.lib.makeBinPath [ env ]
    }:${pathEnv}
  '';
}
