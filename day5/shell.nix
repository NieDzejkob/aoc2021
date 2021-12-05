{ pkgs ? import <nixpkgs> {} }:

with pkgs; mkShell {
  nativeBuildInputs = [ just factor-lang ];
}
