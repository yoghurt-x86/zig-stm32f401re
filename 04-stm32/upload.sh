sudo openocd -f $OPENOCD_PATH/share/openocd/scripts/board/st_nucleo_f4.cfg -c "init; reset halt; flash write_image erase zig-out/bin/blinky.hex; reset run; exit"

