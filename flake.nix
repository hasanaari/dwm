{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages.${system} = {
      dwm = pkgs.dwm.overrideAttrs (old: {
        src = ./.;

        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.makeWrapper];

        postInstall = ''
          wrapProgram $out/bin/dwm \
            --prefix PATH : ${pkgs.lib.makeBinPath [
            pkgs.brightnessctl
            pkgs.wireplumber
            pkgs.flameshot
          ]}
        '';
      });

      default = self.packages.${system}.dwm;
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        pkg-config
        libX11
        libXinerama
        libXft
        freetype
        fontconfig
      ];
    };
  };
}
