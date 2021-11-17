# https://status.nixos.org/
{ pkgs ? (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/ea7d4aa9b822.tar.gz") { })
, lib ? pkgs.lib
, stdenv ? pkgs.stdenv
, ...
}:

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
in
pkgs.mkShell rec {
  name = "nix-on-rails";
  phases = lib.optional stdenv.isLinux [ "unpackPhase" ] ++ [ "noPhase" ];
  noPhase = "mkdir -p $out";

  buildInputs = paths;

  PROJECT_ROOT = ./.;
  GEM_HOME = (toString PROJECT_ROOT + "/.gem/ruby/${ruby.version}");
  LIBRARY_PATH = lib.makeLibraryPath [ env ];
  PATH = builtins.concatStringsSep ":" [
    (toString PROJECT_ROOT + "/bin")
    (toString GEM_HOME + "/bin")
    (toString env + "/bin")
    (builtins.getEnv "PATH")
  ];

  shellHook = ''
    export PGHOST=$(pwd)/tmp/postgres
    export PGDATA=$PGHOST/data
    export PGDATABASE=postgres
    export PGLOG=$PGHOST/postgres.log
    export PGPORT=FILL_IN
    unset CC

    export CPATH=${env}/include:${cpathEnv}
  '';
}
