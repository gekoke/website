{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    resume.url = "github:gekoke/resume";
  };

  outputs = { self, nixpkgs, resume, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      rev = self.sourceInfo.rev or "UNCOMMITTED CHANGES";
      resumePdf = resume.packages.${system}.default;

      mkVariant = name: pkgs.stdenvNoCC.mkDerivation {
        name = "website-${name}";
        src = ./src-variants;
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/public
          cp ${name}.html $out/public/index.html
          chmod +w $out/public/index.html
          ${pkgs.gnused}/bin/sed -i "s|%%GIT_REV%%|${rev}|g" $out/public/index.html
          cp ${resumePdf} $out/public/resume.pdf
          runHook postInstall
        '';
      };

      variants = [
        "terminal"
        "brutalist"
        "amber"
        "greenphos"
        "manuscript"
        "newspaper"
        "bbs"
        "gemini"
        "latex"
        "swiss"
        "mac"
        "win98"
        "markdown"
        "vapor"
        "bluescreen"
        "zen"
        "plaintext"
        "finger"
        "manpage"
        "dotfile"
        "whois"
      ];

      variantPackages = nixpkgs.lib.genAttrs variants mkVariant;
    in
    {
      packages.${system} = variantPackages // {
        default = pkgs.stdenvNoCC.mkDerivation {
          name = "website";
          src = ./src;
          buildPhase = null;
          installPhase = ''
            mkdir -p $out/public
            cp ./* $out/public/
            cp ${resumePdf} $out/public/resume.pdf
          '';
        };

        # `new` = the canonical hacker-terminal variant.
        new = variantPackages.terminal;
      };
    };
}
