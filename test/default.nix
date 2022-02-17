{ pkgs ? (import <nixpkgs> { })
, stdenv ? pkgs.stdenv
, lib ? pkgs.lib
, nix-on-rails ? (import ../shell.nix { })
, ...
}:

stdenv.mkDerivation {
  name = "test-nix-on-rails";
  buildInputs = [
    nix-on-rails
  ];
  phases = lib.optional stdenv.isLinux [ "unpackPhase" ] ++ [ "noPhase" ];
  noPhase = ''
    mkdir $out
    ln -s ${nix-on-rails} $out/nix-on-rails
    ln -s ${./version-test.sh} $out/version-test.sh
    cat <<EOS>> $out/test.sh
#!/bin/sh

sh $out/version-test.sh "$out/nix-on-rails"
EOS
  chmod +x "$out/test.sh"

  sh "$out/test.sh"
  '';
}
