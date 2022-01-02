{ pkgs ? (import <nixpkgs> { })
, stdenv ? pkgs.stdenv
, lib ? pkgs.lib
, nix-on-rails ? (import ../shell.nix { })
, ...
}:

stdenv.mkDerivation {
  name = "test-nix-on-rails";
  phases = lib.optional stdenv.isLinux [ "unpackPhase" ] ++ [ "noPhase" ];
  noPhase = ''
    mkdir $out
    ln -s ${nix-on-rails} $out/nix-on-rails
    ln -s ${./version-test.sh} $out/version-test.sh

    $out/version-test.sh "$out/nix-on-rails"
  '';
}