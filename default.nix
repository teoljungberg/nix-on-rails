let
  nix-on-rails = import ./src/shell.nix { };
  test = import ./test { inherit nix-on-rails; };
in
{
  build = nix-on-rails;
  test = test;
}
