{ pkgs ? import <nixpkgs> { }
, stdenv ? pkgs.stdenv
, lib ? pkgs.lib
, nix-on-rails ? import ../src/shell.nix { }
, version-test ? import ./version-test { }
, ...
}:

stdenv.mkDerivation {
  name = "test-nix-on-rails";
  buildInputs = [ nix-on-rails version-test ];
  src = ./.;
  phases = lib.optional stdenv.isLinux [ "unpackPhase" ] ++ [ "noPhase" ];
  noPhase = ''
    mkdir $out
    ln -s ${nix-on-rails} $out/nix-on-rails
    ln -s ${version-test} $out/version-test

    touch "$out/test.sh"
    chmod +x "$out/test.sh"
    cat <<EOS>> $out/test.sh
#!/bin/sh

sh $out/version-test/test.sh $out/nix-on-rails
EOS

  sh "$out/test.sh"
  '';
}
