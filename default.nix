let
  build-nix-on-rails = import ./shell.nix { };
  test-nix-on-rails = import ./test {
    nix-on-rails = build-nix-on-rails;
  };
in
{
  build = build-nix-on-rails;
  test = test-nix-on-rails;
}
