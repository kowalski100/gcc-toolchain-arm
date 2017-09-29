# Building GCC toolchain for ARM

This script is written to build gcc-toolchain for ARMv7 mainly cortex-m profile. The script automatically download and install GNU binutils, gcc, newlib, and gdb. The default target is <B>arm-none-eabi</B> while the installation directory is <B>/opt/tools/arm-none-eabi</B>

<B>USAGE</B>              :       bash script.sh {ARGS}(OR) ./script.sh {ARGS}  => SubShell

<B>ARGS</B>               :       EXTD (if toolchain components arealdy extracted), leave blank otherwise e.g. <B>bash script.sh extd</B>
