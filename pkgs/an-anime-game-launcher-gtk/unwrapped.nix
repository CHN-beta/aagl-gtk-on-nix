{
lib, rustPlatform, fetchFromGitHub
, pkg-config
, openssl
, glib
, pango
, gdk-pixbuf
, gtk4
, jq
, libadwaita
, gobject-introspection
, gsettings-desktop-schemas
, wrapGAppsHook4
, librsvg
, python3
, python3Packages

, customDxvk ? null
, customDxvkAsync ? null
, customGEProton ? null
, customLutris ? null
, customSoda ? null
, customWineGEProton ? null
, customIcon ? null
}:

with lib;

let
  overrideDXVK = {
    dxvk ? "vanilla",
    name ? "dxvk-${version}",
    url,
    version
  }:
  let
    json = "components/dxvk/${dxvk}.json";
  in
  ''
    newJson="$(jq -r '. |= [{
      "name": "${name}",
      "version": "${version}",
      "uri": "${url}",
      "recommended": true
    }] + .' ${json})"
    echo "$newJson" > ${json}
  '';

  overrideWine = {
    wine ? (toLower name),
    fullname ? "${wine}-${version}-x86_64",
    title ? "${name} ${version}",
    name,
    url,
    version,
    files ? null
  }:
  let
    json = "components/wine/${wine}.json";
    # Take default arguments for the files attrset
    files_ = let
      default = {
        wine = "bin/wine";
        wine64 = "bin/wine64";
        wineboot = "bin/wineboot";
        winecfg = "lib64/wine/x86_64-windows/winecfg.exe";
        wineserver = "bin/wineserver";
      };
    in
    if (builtins.isAttrs files)
    then ( default // files )
    else default;
  in
  ''
    newJson="$(jq -r '. |= [{
      "name": "${fullname}",
      "title": "${title}",
      "uri": "${url}",
      "files": {
        "wine": "${files_.wine}",
        "wine64": "${files_.wine64}",
        "wineserver": "${files_.wineserver}",
        "wineboot": "${files_.wineboot}",
        "winecfg": "${files_.winecfg}"
      },
      "recommended": true
    }] + .' ${json})"
    echo "$newJson" > ${json}
  '';
in

rustPlatform.buildRustPackage rec {
  pname = "an-anime-game-launcher-gtk";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "an-anime-team";
    repo = "an-anime-game-launcher-gtk";
    rev = version;
    sha256 = "sha256-2I3/J173Gn1FA/7wO659hkNHnMLKA9G1Bux/wktySQ4=";
    fetchSubmodules = true;
  };

  prePatch = ''''
    + optionalString (builtins.isPath customIcon || builtins.isString customIcon) ''
      rm assets/images/icon.png
      cp ${customIcon} assets/images/icon.png
    ''

    + optionalString (builtins.isAttrs customDxvk) (overrideDXVK customDxvk)
    + optionalString (builtins.isAttrs customDxvkAsync) (overrideDXVK ( rec {
      inherit (customDxvkAsync) url version;
      dxvk = "async";
      name = "dxvk-async-${version}";
    } // customDxvkAsync))

    # Override GE-Proton
    + optionalString (builtins.isAttrs customGEProton) (overrideWine ( rec {
      inherit (customGEProton) url version;
      name = "GE-Proton";
      fullname = "${name}${version}";
      files = {
        wine64 = "files/bin/wine64";
        wineboot = "files/bin/wineboot";
        winecfg = "files/lib64/wine/x86_64-windows/winecfg.exe";
        wineserver = "files/bin/wineserver";
      };
    } // customGEProton))

    # override Lutris
    + optionalString (builtins.isAttrs customLutris) (overrideWine ( rec {
      inherit (customLutris) url version;
      name = "Lutris";
    } // customLutris))

    # override Soda
    + optionalString (builtins.isAttrs customSoda) (overrideWine ( rec {
      inherit (customSoda) url version;
      name = "Soda";
      files.winecfg = "lib/wine/x86_64-windows/winecfg.exe";
    } // customSoda))

    # override Wine-GE-Proton
    + optionalString (builtins.isAttrs customWineGEProton) (overrideWine ( rec {
      inherit (customWineGEProton) url version;
      name = "Wine-GE-Proton";
      fullname = "lutris-GE-Proton${version}-x86_64";
    } // customWineGEProton));

  cargoSha256 = "sha256-s67mSAPXYVddAxRW2crE/16PvCkzVylW1bnrBYrpukI=";

  nativeBuildInputs = [
    glib
    gobject-introspection
    gtk4
    jq
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
