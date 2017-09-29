# Building GCC toolchain for ARM

This script is written to build gcc-toolchain for ARMv7 mainly cortex-m profile. The script automatically download and install GNU binutils, gcc, newlib, and gdb. The default settings are <B>arm-none-eabi<B>.

USAGE              :bash script.sh {ARGS}(OR) ./script.sh {ARGS}  => SubShell

ARGS               :EXTD (if toolchain components arealdy extracted), leave blank otherwise
