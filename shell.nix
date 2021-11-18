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

  makeCpath = lib.makeSearchPath "include";
in
pkgs.mkShell rec {
  name = "nix-on-rails";
  phases = lib.optional stdenv.isLinux [ "unpackPhase" ] ++ [ "noPhase" ];
  noPhase = "mkdir -p $out";
  buildInputs = paths;

  PROJECT_ROOT = toString ./. + "/";
  GEM_HOME = (PROJECT_ROOT + "/.gem/ruby/${ruby.version}");
  LIBRARY_PATH = lib.makeLibraryPath [ env ];
  CPATH = makeCpath [ env ];
  PATH = builtins.concatStringsSep ":" [
    (lib.makeBinPath [ PROJECT_ROOT GEM_HOME env ])
    (builtins.getEnv "PATH")
  ];

  shellHook = ''
    export PGHOST=$(pwd)/tmp/postgres
    export PGDATA=$PGHOST/data
    export PGDATABASE=postgres
    export PGLOG=$PGHOST/postgres.log
    export PGPORT=FILL_IN
    unset CC
  '';
}
