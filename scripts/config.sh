# EDIT THESE
OSNAME=lizarx
NCPU=grep -c ^processor /proc/cpuinfo

BINUTILS_VER=2.23.2
GCC_VER=4.8.1
GMP_VER=5.1.0
MPFR_VER=3.1.1
NEWLIB_VER=2.0.0
MPC_VER=1.0.1
PPL_VER=1.0
CLOOG_VER=0.18.0

AUTOCONF_VER=2.68
AUTOMAKE_VER=1.11.6
export I386_TARGET=i386-pc-${OSNAME}
export X86_64_TARGET=x86_64-pc-${OSNAME}
export TARGET=$I386_TARGET

WFLAGS=-c
