{ pkgs ? import <nixpkgs> {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    elm2nix
    elmPackages.elm
    elmPackages.elm-format
    elmPackages.elm-test
    elmPackages.elmi-to-json
    nodePackages.elm-oracle
    nodejs
  ];
}
