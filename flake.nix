{
  description = "Fosforus - Tauri wallpaper gallery";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url = "github:nix-community/nixGL";
  };
  outputs = { self, nixpkgs, flake-utils, nixgl }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nixglPkg = nixgl.packages.${system}.nixGLIntel;
        libraries = with pkgs; [
          gtk3
          glib
          gdk-pixbuf
          cairo
          pango
          dbus
          openssl
          libsoup_3
          webkitgtk_4_1
          librsvg
        ];
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            pkg-config
            wrapGAppsHook4
          ];
          buildInputs = libraries ++ (with pkgs; [
            cargo
            cargo-tauri
            rustc
            pnpm
            nixglPkg
          ]);

          shellHook = ''
            echo "HELLO WORLD"
            export WEBKIT_DISABLE_DMABUF_RENDERER="1"
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH"
            export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"
            alias tauri-dev="${nixglPkg}/bin/nixGLIntel pnpm tauri dev"
            echo "Run 'tauri-dev' to start with nixGL wrapping"
          '';
        };
      });
}