#!/bin/bash       

#title              :script.sh

#description        :This script is written to build gcc-toolchain for ARMv7 mainly
#                    cortex-m profile. The script automatically download and install
#                    GNU binutils, gcc, newlib, and gdb.

#author             :Ijaz Ahmad

#date               :20170926

#version            :v1.0

#USAGE              :bash script.sh {ARGS}(OR) ./script.sh {ARGS}  => SubShell

#ARGS               :EXTD (if toolchain components arealdy extracted), leave blank otherwise

#bash_version       :4.4.12(1)-release

#=======================================================================================
#NOTE: The script is provided "AS IS", wihtout warrenty of ANY KIND.
#=======================================================================================

#GNU TOOLCHAIN BUILD COMPONENTS VERSION INFORMATION

#Binutils       :v2.28
#GCC            :v6.4.0
#newlib         :v2.5.0
#GDB            :v8.0

#=======================================================================================
#NOTE: use 'dos2unix script.sh' if you see errors Like: $'\r': command not found
#=======================================================================================

#Already extracted tar files
#Use EXTD or extd command line argument if toolchain components were extracted previously
SWITCH_EXTRACTED=$1

TARGET=arm-none-eabi                        #Possible Options: arm-elf, arm-none-linux-eabi, arm-eabi, arm-none-linux-gnueabi etc.
#NOTE: DON'T ADD ANY TRAILING '/'
PREFIX=/opt/tools/arm-none-eabi             #Toolchain installation directory.
BUILD_DIR=/home/`whoami`/arm-toolchain      #Directory where the toolchain will be downloaded and build

BINUTILS_VERSION=binutils-2.28.tar.gz
GCC_VERSION=gcc-6.4.0.tar.gz
NEWLIB_VERSION=newlib-2.5.0.tar.gz
GDB_VERSION=gdb-8.0.tar.gz

function quitProcess () {
	if [ $? -ne 0 ]; then
      echo $1
	  echo "Exiting Script. :-("
      exit 2
	else
	  echo $2
	  echo ""
	fi
}

function errorExists () {
    if [ "$TMP" != "" ]
    then
	   0==1 > /dev/null 2>&1  #just to change status variable
    fi
}

mkdir -p $BUILD_DIR
cd $BUILD_DIR

#=======================================================================================
#                      Downloading all toolchain components                            #
#=======================================================================================

#Downloading binutils.
echo -n "Downloading Binutils..."
if [ ! -e $BINUTILS_VERSION ] 
then
    wget https://ftp.gnu.org/gnu/binutils/$BINUTILS_VERSION
fi

quitProcess "Error downloading $BINUTILS_VERSION..." "Download Complete."

#Downloading GCC
echo -n "Downloading GCC... "
if [ ! -e $GCC_VERSION ]
then
    wget ftp.gnu.org/gnu/gcc/gcc-6.4.0/$GCC_VERSION
fi

quitProcess "Error downloading $GCC_VERSION..." "Download Complete."

#Downloading newLib
echo -n "Downloading newlib... "
if [ ! -e $NEWLIB_VERSION ]
then
    wget ftp://sourceware.org/pub/newlib/$NEWLIB_VERSION
fi

quitProcess "Error downloading $NEWLIB_VERSION..." "Download Complete."

#Downloading GDB
echo -n "Downloading gdb... "
if [ ! -e $GDB_VERSION ]
then
    wget ftp.gnu.org/gnu/gdb/$GDB_VERSION
fi

quitProcess "Error downloading $GDB_VERSION..." "Download Complete"

#=======================================================================================
#                      Extracting all downlaoded components                            #
#=======================================================================================

if [ "$SWITCH_EXTRACTED" != "EXTD" ] && [ "$SWITCH_EXTRACTED" != "extd" ]
then

    echo -n "Extracting $BINUTILS_VERSION... "
    tar  xzf  $BINUTILS_VERSION
    quitProcess "Error extracting $BINUTILS_VERSION." "done"

    echo -n "Extracting $GCC_VERSION... "
    tar  xzf  $GCC_VERSION
    quitProcess "Error extracting $GCC_VERSION." "done"

    echo -n "Extracting $NEWLIB_VERSION... "
    tar  xzf  $NEWLIB_VERSION
    quitProcess "Error extracting $NEWLIB_VERSION." "done"

    echo -n "Extracting $GDB_VERSION... "
    tar  xzf  $GDB_VERSION
    quitProcess "Error extracting $GDB_VERSION." "done"

else
  echo "Toolchain components already extracted..."
fi

#=======================================================================================
#                             Creating Build Directories                               #
#=======================================================================================

mkdir -p binutils-build gcc-build newlib-build gdb-build

#=======================================================================================
#                                 Building Binutils                                    #
#=======================================================================================
echo "Building ${BINUTILS_VERSION::-7}... "

cd binutils-build/

../${BINUTILS_VERSION::-7}/configure --target=$TARGET --prefix=$PREFIX  2>&1 | tee ../binutils-log.log   #additional switches may be added here

make all install 2>&1 | tee -a ../binutils-log.log

TMP=`cat ../binutils-log.log | grep -iP "( )error." | grep -v "errors.o"`

errorExists $TMP

quitProcess "Error building ${BINUTILS_VERSION::-7}, for more details refer to build logs in binutils-log.log" "Binutils build successfully..."

PATH=$PREFIX/bin:$PATH

cd ..

#=======================================================================================
#                                    Building GCC                                      #
#=======================================================================================

echo "Building ${GCC_VERSION::-7}... "

cd ${GCC_VERSION::-7}

./contrib/download_prerequisites

cd ..

cd gcc-build

../${GCC_VERSION::-7}/configure --target=$TARGET --prefix=$PREFIX --enable-language=c,c++ --without-headers --with-newlib  2>&1 | tee ../gcc-log.log  #additional switches may be added here

make all-gcc install-gcc 2>&1 | tee -a ../gcc-log.log

TMP=`cat ../gcc-log.log | grep -iP "( )error." | grep -v "errors.o"`

errorExists $TMP

quitProcess "Error building ${GCC_VERSION::-7}, for more details refer to build logs in gcc-log.log" "GCC build successfully..."

cd ..

#=======================================================================================
#                                   Building NewLib                                    #
#=======================================================================================

echo "Building ${NEWLIB_VERSION::-7}... "

cd newlib-build

../${NEWLIB_VERSION::-7}/configure --target=$TARGET --prefix=$PREFIX    2>&1 | tee ../newlib-log.log           #additional switches may be added here

make all install 2>&1 | tee -a ../newlib-log.log

TMP=`cat ../newlib-log.log | grep -iP "( )error." | grep -v "errors.o"`

errorExists $TMP

quitProcess "Error building ${NEWLIB_VERSION::-7}, for more details refer to build logs in newlib-log.log" "NewLib build successfully..."

cd ..

#=======================================================================================
#                                Building GCC Compiler                                 #
#=======================================================================================

echo "Building GCC C/C++ Compiler for ARM..."

cd gcc-build

../gcc-6.4.0/configure --target=$TARGET --prefix=$PREFIX --enable-language=c,c++ --with-newlib  2>&1 | tee ../gcc-withNewlib-log.log       #additional switches may be added here

make all-gcc install-gcc 2>&1 | tee -a ../gcc-withNewlib-log.log

TMP=`cat ../gcc-withNewlib-log.log | grep -iP "( )error." | grep -v "errors.o"`

errorExists $TMP

quitProcess "Error building GCC Compiler, for more details refer to build logs in gcc-withNewlib-log.log" "GCC Compiler with NewLib build successfully..."

cd ..

#=======================================================================================
#                                     Building GDB                                     #
#=======================================================================================
echo "Building GDB... "

cd gdb-build/

../gdb-8.0/configure --target=$TARGET --prefix=$PREFIX 2>&1 | tee ../gdb-log.log                    #additional switches may be added here

make all install 2>&1 | tee -a ../gdb-log.log

TMP=`cat ../gdb-log.log | grep -iw "error."`

errorExists $TMP

quitProcess "Error building GDB, for more details refer to build logs in gdb-log.log" "GDB build successfully..."

cd ..

#=======================================================================================
#                              TOOLCHAIN BUILD SUCCESSFULLY                            #
#=======================================================================================

echo "*********************************************************************************"
echo "*                        TOOLCHAIN BUILD SUCCESSFULLY                            *"
echo "*********************************************************************************"
