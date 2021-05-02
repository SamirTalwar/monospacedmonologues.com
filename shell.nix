{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  buildInputs = [
    niv
    nixpkgs-fmt

    awscli
    gnumake
    hugo
    terraform_0_15
  ];
}
