{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # poetry2nix = {
    #   url = "github:nix-community/poetry2nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  # dev
  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = with inputs; [
            devshell.overlay
            # poetry2nix.overlay
          ];
        };
      in {
        devShells.default = pkgs.devshell.mkShell {
          packages = with pkgs; [
            alejandra
            treefmt
            taplo-cli
            black
            maven
            (python310.withPackages (pp:
              with pp; [
                ujson
                jinja2
              ]))
            # gcc-unwrapped
          ];
          commands = [
            {
              package = "treefmt";
              category = "formatter";
            }
          ];
        };
        devShells.poetry = pkgs.poetry2nix.mkPoetryEnv {
          projectDir = ./.;
        };
      }
    );
}
