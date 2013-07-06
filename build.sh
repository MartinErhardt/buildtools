#function foo ->foo()
#source -> .
#
. scripts/functions.sh

# --- Variables ---
. scripts/config.sh

F_ARCH_X86_64="--arch-x86_64"

if [ "$1" == $F_ARCH_X86_64 ] || [ "$2" == $F_ARCH_X86_64 ]
then
	export TARGET=$X86_64_TARGET
	GCC_VER=4.6.3
fi

PREFIX=`pwd`/$TARGET

export PATH=$PREFIX/bin:$PATH

if [ $CLEAN -eq 1 ]; then
		rm -rf $PREFIX build/*/
fi

# --- Directory creation ---

mkdir -p build
mkdir -p $PREFIX
cd build

setphase "MAKE OBJECT DIRECTORIES"
rm -rf binutils-obj
rm -rf gcc-obj
rm -rf newlib-obj
rm -rf gmp-obj
rm -rf mpfr-obj
rm -rf mpc-obj
rm -rf autoconf-obj
rm -rf automake-obj
#rm -rf $PREFIX
mkdir -p binutils-obj
mkdir -p gcc-obj
mkdir -p newlib-obj
mkdir -p gmp-obj
mkdir -p mpfr-obj
mkdir -p mpc-obj

mkdir -p autoconf-obj
mkdir -p automake-obj
#mkdir -p $PREFIX
# --- Fetch and extract each package ---
. ../scripts/fetchandpatch.sh

# --- Compile all packages ---

setphase "COMPILE BINUTILS"
cd binutils-obj
../binutils-${BINUTILS_VER}/configure --target=$TARGET --prefix=$PREFIX --disable-werror --enable-gold --enable-plugins || exit
make -j$NCPU all-gold || exit
make -j$NCPU || exit
make install || exit
cd ..
setphase "COMPILE GMP"
cd gmp-obj
../gmp-${GMP_VER}/configure --prefix=$PREFIX --enable-cxx --disable-shared || exit
make -j$NCPU || exit
if [ $NOTEST -ne 1 ]; then
		make check || exit
fi
make install || exit
cd ..

setphase "COMPILE MPFR"
cd mpfr-obj
../mpfr-${MPFR_VER}/configure --prefix=$PREFIX --with-gmp=$PREFIX --disable-shared
make -j$NCPU || exit
if [ $NOTEST -ne 1 ]; then
		make check || exit
fi
make install || exit
cd ..

setphase "COMPILE MPC"
cd mpc-obj
../mpc-${MPC_VER}/configure --target=$TARGET --prefix=$PREFIX --with-gmp=$PREFIX --with-mpfr=$PREFIX --disable-shared || exit
make -j$NCPU || exit
if [ $NOTEST -ne 1 ]; then
		make check || exit
fi
make install || exit
cd ..


setphase "AUTOCONF GCC"
cd gcc-${GCC_VER}/libstdc++-v3
#autoconf || exit
cd ../..

setphase "COMPILE GCC"
cd gcc-obj
../gcc-${GCC_VER}/configure --target=$TARGET --prefix=$PREFIX --enable-languages=c,c++ --disable-libssp --with-gmp=$PREFIX --with-mpfr=$PREFIX --with-mpc=$PREFIX --disable-nls --with-newlib --enable-shared|| exit
make -j3 all-gcc || exit
make install-gcc || exit
cd ..

setphase "COMPILE AUTOCONF"
cd autoconf-obj
../autoconf-${AUTOCONF_VER}/configure --prefix=$PREFIX || exit
make -j$NCPU all || exit
make install || exit
cd ..

setphase "COMPILE AUTOMAKE"
cd automake-obj
../automake-${AUTOMAKE_VER}/configure --prefix=$PREFIX || exit
make -j$NCPU all || exit
make install || exit
cd ..

cd ../$TARGET/share
ln -s aclocal-1.11 aclocal
cd ../../build

hash -r

setphase "AUTOCONF NEWLIB-XOMB"
cd newlib-${NEWLIB_VER}/newlib/libc/sys
autoconf || exit
cd ${OSNAME}
autoreconf || exit
cd ../../../../..

setphase "CONFIGURE NEWLIB"
cd newlib-obj
../newlib-${NEWLIB_VER}/configure --target=$TARGET --prefix=$PREFIX --with-gmp=$PREFIX --with-mpfr=$PREFIX -enable-newlib-hw-fp || exit

setphase "COMPILE NEWLIB"
make -j$NCPU || exit
make install || exit
cd ..

setphase "PASS-2 COMPILE GCC"
cd gcc-obj
#make all-target-libgcc
#make install-target-libgcc
make -j$NCPU all-target-libstdc++-v3 || exit
make install-target-libstdc++-v3 || exit
make -j$NCPU all || exit
make install || exit
cd ..

setphase "PASS-2 COMPILE NEWLIB"
cp ../arch/${TARGET}/newlib-files/vanilla-syscalls.c newlib-${NEWLIB_VER}/newlib/libc/sys/${OSNAME}/syscalls.c

cd newlib-obj
../newlib-${NEWLIB_VER}/configure --target=$TARGET --prefix=$PREFIX --with-gmp=$PREFIX --with-mpfr=$PREFIX -enable-newlib-hw-fp || exit
make -j$NCPU || exit
make install || exit
cd ..
