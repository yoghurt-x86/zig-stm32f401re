# Zig project for stm32f401re

Find the cubemx hal output in ./stm32_hal

builds by running `zig build` 

However, i cannot flash the board from the output: 
`sudo openocd -f $OPENOCD_PATH/share/openocd/scripts/board/st_nucleo_f4.cfg -c "init; reset halt; flash write_image erase zig-out/bin/blinky.hex; reset run; exit"`

I get the error:
```
Warn : no flash bank found for address 0x00010134
Warn : no flash bank found for address 0x00022810
```


But the program from the cubemx Makefile can flash with no modifications needed! 

If i run `make` on the cubemx project in the `stm32_hal` folder
I can flash the board with:
`sudo openocd -f $OPENOCD_PATH/share/openocd/scripts/board/st_nucleo_f4.cfg -c "init; reset halt; flash write_image erase build/cubemx.hex; reset run; exit"`



If I adjust the MakeFile to use `zig cc` to compile it still works.
However i don't know why the `zig build` doesn't work still. 
