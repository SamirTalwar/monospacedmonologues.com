{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  buildInputs = [
    niv
    nixpkgs-fmt

    awscli2
    coreutils
    gnumake
    hugo
    terraform_0_15
  ];
}
