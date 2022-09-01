{ pkgs ? import <nixpkgs> { }
, stdenv ? pkgs.stdenv
, lib ? pkgs.lib
, ...
}:

stdenv.mkDerivation {
  name = "test-nix-on-rails-version-test";
  src = ./.;
  phases = lib.optional stdenv.isLinux [ "unpackPhase" ] ++ [ "noPhase" ];
  noPhase = ''
    mkdir $out
    ln -s ${./test.sh} $out/test.sh
  '';
}
