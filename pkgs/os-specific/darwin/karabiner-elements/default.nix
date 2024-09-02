{
  lib,
  stdenv,
  fetchurl,
  cpio,
  xar,
  undmg,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "karabiner-elements";
  version = "14.13.0";

  src = fetchurl {
    url = "https://github.com/pqrs-org/Karabiner-Elements/releases/download/v${finalAttrs.version}/Karabiner-Elements-${finalAttrs.version}.dmg";
    sha256 = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
  };

  outputs = [
    "out"
    "driver"
  ];

  nativeBuildInputs = [
    cpio
    xar
    undmg
  ];

  unpackPhase = ''
    undmg $src
    xar -xf Karabiner-Elements.pkg
    cd Installer.pkg
    zcat Payload | cpio -i
    cd ../Karabiner-DriverKit-VirtualHIDDevice.pkg
    zcat Payload | cpio -i
    cd ..
  '';

  sourceRoot = ".";

  postPatch = ''
    for f in *.pkg/Library/Launch{Agents,Daemons}/*.plist; do
      substituteInPlace $f \
        --replace "/Library/" "$out/Library/"
    done
  '';

  installPhase = ''
    mkdir -p $out $driver
    cp -R Installer.pkg/Applications Installer.pkg/Library $out
    cp -R Karabiner-DriverKit-VirtualHIDDevice.pkg/Applications Karabiner-DriverKit-VirtualHIDDevice.pkg/Library $driver

    cp "$out/Library/Application Support/org.pqrs/Karabiner-Elements/package-version" "$out/Library/Application Support/org.pqrs/Karabiner-Elements/version"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/pqrs-org/Karabiner-Elements/releases/tag/v${finalAttrs.version}";
    description = "Karabiner-Elements is a powerful utility for keyboard customization on macOS Ventura (13) or later";
    homepage = "https://karabiner-elements.pqrs.org/";
    license = lib.licenses.unlicense;
    maintainers = [ ];
    platforms = lib.platforms.darwin;
  };
})
