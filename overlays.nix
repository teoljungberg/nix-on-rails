[
  (self: super: {
    rubyXY = super.ruby_3_1.overrideAttrs (oldAttrs: rec {
      version = "X.Y.Z";

      src = super.fetchurl {
        url = "https://cache.ruby-lang.org/pub/ruby/X.Y/ruby-X.Y.Z.tar.gz";
        sha256 = "0000000000000000000000000000000000000000000=";
      };

      patches = [ ];
      postPatch = "";
    });
  })
]
