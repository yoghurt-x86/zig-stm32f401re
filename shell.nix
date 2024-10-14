{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [ 
      gcc-arm-embedded 
      openocd
      screen
      bear
      gdb
      zig
    ];

    shellHook = ''
        echo "Hello shell"
        export GCC_PATH="${pkgs.gcc-arm-embedded}/bin"
        export OPENOCD_PATH="${pkgs.openocd}"
      '';
}
