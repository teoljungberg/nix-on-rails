{ pkgs ? (import <nixpkgs> { })
, ...
}:

let
  nix-on-rails = import ./shell.nix;
in
{
  build = nix-on-rails;
  test = pkgs.runCommand
    (
      "test-nix-on-rails"
        {
          buildInputs = [ nix-on-rails ];
        }
        "bash ${./test/version-test.sh} ${nix-on-rails}"
    );
}
