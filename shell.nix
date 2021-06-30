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
    name = "nix-on-rails-env";
    paths = paths;
    extraOutputsToInstall = [ "bin" "lib" "include" ];
  };

  cpathEnv = builtins.getEnv "CPATH";
  libraryPathEnv = builtins.getEnv "LIBRARY_PATH";
  pathEnv = builtins.getEnv "PATH";
in pkgs.mkShell {
  name = "nix-on-rails";
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

    export CPATH=${env}/include:${cpathEnv}
    export LIBRARY_PATH=${env}/lib:${libraryPathEnv}
    PATH=$HOME/.gem/ruby/${ruby.version}/bin:${env}/bin:${pathEnv}
  '';
}
