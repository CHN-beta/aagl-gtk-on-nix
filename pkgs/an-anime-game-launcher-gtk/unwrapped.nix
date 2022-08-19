{ lib, rustPlatform, fetchFromGitLab
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
  version = "1.0.1";

  src = fetchFromGitLab {
    owner = "an-anime-team";
    repo = "an-anime-game-launcher-gtk";
    rev = version;
    sha256 = "sha256-14HfQ7RJsIZGM/tMZ5vtV0j2eMpQIGLSXCpG+ANqxnM=";
    fetchSubmodules = true;
  };

  prePatch = ''''
    + optionalString (builtins.isPath customIcon || builtins.isString customIcon) ''
      rm assets/images/icon.png
      cp ${customIcon} assets/images/icon.png
    '';

  cargoSha256 = "sha256-puvCwqAaQMXHBizA3bO+uOBF1KnpEPn5rEJuMxLHtBM=";

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
