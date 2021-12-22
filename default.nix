{ pkgs ? (import <nixpkgs> { })
, stdenv ? pkgs.stdenv
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

      sh ${./test/version-test.sh} ${nix-on-rails}
    '';
  };
in
{
  build = nix-on-rails;
  test = test-derivation;
}
