# https://status.nixos.org/
{ pkgs ? (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7fad01d9d5a3.tar.gz") { })
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
  makePathExpression = new:
    builtins.concatStringsSep ":" [ new (builtins.getEnv "PATH") ];
in
pkgs.mkShell rec {
  name = "nix-on-rails";
  phases = lib.optional stdenv.isLinux [ "unpackPhase" ] ++ [ "noPhase" ];
  noPhase = "mkdir -p $out";
  buildInputs = paths;

  PROJECT_ROOT = toString ./. + "/";

  CPATH = makeCpath [ env ];
  GEM_HOME = PROJECT_ROOT + "/.gem/ruby/${ruby.version}";
  LIBRARY_PATH = lib.makeLibraryPath [ env ];
  PATH = makePathExpression (lib.makeBinPath [ PROJECT_ROOT GEM_HOME env ]);

  PGHOST = PROJECT_ROOT + "/tmp/postgres";
  PGDATA = PGHOST + "/data";
  PGDATABASE = "postgres";
  PGLOG = PGHOST + "/postgres.log";
  PGPORT = "FILL_IN";

  shellHook = ''
    unset CC

    export PATH=${PATH}:$PATH

    ${PROJECT_ROOT}/bin/mainframe up
  '';
}
