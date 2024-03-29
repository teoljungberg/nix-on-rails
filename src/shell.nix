# https://status.nixos.org/
{ pkgs ? (
    import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/22.11.tar.gz") {
      # overlays = import ./overlays.nix;
    }
  )
, lib ? pkgs.lib
, stdenv ? pkgs.stdenv
, ...
}:

let
  postgresql = pkgs.postgresql_15;
  redis = pkgs.redis;
  ruby = (
    import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/22.11.tar.gz") { }
  ).ruby_3_1;
  paths = with pkgs; [
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

  makeCpath = lib.makeSearchPathOutput "include" "include";
  makePathExpression = new:
    builtins.concatStringsSep ":" [ new (builtins.getEnv "PATH") ];
in
pkgs.mkShell rec {
  name = "nix-on-rails";
  phases = lib.optional stdenv.isLinux [ "unpackPhase" ] ++ [ "noPhase" ];
  noPhase = ''
    mkdir -p $out/bin
    ln -s ${env}/bin/* $out/bin/
  '';
  buildInputs = paths;
  src = ./.;

  PROJECT_ROOT = toString ./. + "/";

  CPATH = makeCpath [ env ];
  GEM_HOME = PROJECT_ROOT + "/.gem/ruby/${ruby.version}";
  LIBRARY_PATH = lib.makeLibraryPath [ env ];
  PATH = makePathExpression (lib.makeBinPath [ PROJECT_ROOT GEM_HOME env ]);

  PGHOST = PROJECT_ROOT + "/tmp/postgres";
  PGDATA = PGHOST + "/data";
  PGDATABASE = "postgres";
  PGLOG = PGHOST + "/postgres.log";
  PGPORT = "5432";

  shellHook = ''
    unset CC

    export PATH=${PATH}:$PATH
  '';
}
