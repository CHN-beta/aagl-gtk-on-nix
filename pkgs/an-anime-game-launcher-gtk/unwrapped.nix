{ lib, rustPlatform, fetchFromGitHub
, pkg-config
, openssl
, glib
, pango
, gdk-pixbuf
, gtk4
, libadwaita
, gobject-introspection
, gsettings-desktop-schemas
, wrapGAppsHook4
, librsvg
, python3
, python3Packages
, customIcon ? null
}:

with lib;
rustPlatform.buildRustPackage rec {
  pname = "an-anime-game-launcher-gtk";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "an-anime-team";
    repo = "an-anime-game-launcher-gtk";
    rev = version;
    sha256 = "sha256-5mo0g5vZZPQBch9KWVuaoWau2ATJFDYlQ7sSV2KC1oQ=";
    fetchSubmodules = true;
  };

  prePatch = ''''
    + optionalString (builtins.isPath customIcon || builtins.isString customIcon) ''
      rm assets/images/icon.png
      cp ${customIcon} assets/images/icon.png
    '';

  cargoSha256 = "sha256-IkuG/1S84Rleik8qliRyMFzwL+rxFoJu/oXWElfU4e4=";

  nativeBuildInputs = [
    glib
    gobject-introspection
    gtk4
    pkg-config
    python3
    python3Packages.pygobject3
    wrapGAppsHook4
  ];

  buildInputs = [
    gdk-pixbuf
    gsettings-desktop-schemas
    libadwaita
    librsvg
    openssl
    pango
  ];
}
