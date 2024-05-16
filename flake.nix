{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    resume.url = "github:gekoke/resume";
  };

  outputs = { nixpkgs, resume, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.default = pkgs.stdenvNoCC.mkDerivation {
        name = "website";
        src = ./src;
        buildPhase = null;
        installPhase = ''
          mkdir -p $out/public
          cp ${resume.packages.${system}.default}/resume.pdf ./* $out/public/
        '';
      };
    };
}
