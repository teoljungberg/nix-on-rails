{ pkgs ? (import <nixpkgs> { })
, stdenv ? pkgs.stdenvNoCC
, lib ? pkgs.lib
, ...
}:

let
  nix-on-rails = import ./shell.nix { };
  test-derivation = stdenv.mkDerivation rec {
    name = "test-nix-on-rails";
    buildInputs = [
      nix-on-rails
      ./test
    ];
    phases = lib.optional stdenv.isLinux [ "unpackPhase" ] ++ [ "noPhase" ];
    noPhase = ''
      mkdir $out
      ln -s ${nix-on-rails} $out/nix-on-rails
      ln -s ${./test/version-test.sh} $out/version-test.sh

      sh $out/version-test.sh $out/nix-on-rails
    '';
  };
in
{
  build = nix-on-rails;
  test = test-derivation;
}
