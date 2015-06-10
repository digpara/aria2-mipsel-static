#!/bin/bash

set -e
set -x

mkdir ~/aria2 && cd ~/aria2

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
RPATH=/opt/lib
DEST=$BASE/opt
LDFLAGS="-L$DEST/lib -Wl,--gc-sections"
CPPFLAGS="-I$DEST/include"
CFLAGS="-mtune=mips32 -mips32 -O3 -ffunction-sections -fdata-sections"	
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=/opt --host=mipsel-linux"
MAKE="make -j`nproc`"
mkdir $SRC

######## ####################################################################
# ZLIB # ####################################################################
######## ####################################################################

mkdir $SRC/zlib && cd $SRC/zlib
$WGET http://zlib.net/zlib-1.2.8.tar.gz
tar zxvf zlib-1.2.8.tar.gz
cd zlib-1.2.8

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
CROSS_PREFIX=mipsel-linux- \
./configure \
--prefix=/opt

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# OPENSSL # #################################################################
########### #################################################################

mkdir -p $SRC/openssl && cd $SRC/openssl
$WGET https://www.openssl.org/source/openssl-1.0.2a.tar.gz
tar zxvf openssl-1.0.2a.tar.gz
cd openssl-1.0.2a

./Configure linux-mips32 \
-mtune=mips32 -mips32 \
-ffunction-sections -fdata-sections -Wl,--gc-sections \
--prefix=/opt shared zlib \
--with-zlib-lib=$DEST/lib \
--with-zlib-include=$DEST/include

make CC=mipsel-linux-gcc
make CC=mipsel-linux-gcc install INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl

########## ##################################################################
# SQLITE # ##################################################################
########## ##################################################################

mkdir $SRC/sqlite && cd $SRC/sqlite
$WGET https://www.sqlite.org/2015/sqlite-autoconf-3081002.tar.gz --no-check-certificate
tar zxvf sqlite-autoconf-3081002.tar.gz
cd sqlite-autoconf-3081002

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# LIBXML2 # #################################################################
########### #################################################################

mkdir $SRC/libxml2 && cd $SRC/libxml2
$WGET ftp://xmlsoft.org/libxml2/libxml2-2.9.2.tar.gz
tar zxvf libxml2-2.9.2.tar.gz
cd libxml2-2.9.2

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--with-zlib=$DEST \
--without-python

$MAKE LIBS="-lz"
make install DESTDIR=$BASE

########## ##################################################################
# C-ARES # ##################################################################
########## ##################################################################

mkdir $SRC/c-ares && cd $SRC/c-ares
$WGET http://c-ares.haxx.se/download/c-ares-1.10.0.tar.gz
tar zxvf c-ares-1.10.0.tar.gz
cd c-ares-1.10.0

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# LIBSSH2 # #################################################################
########### #################################################################

mkdir $SRC/libssh2 && cd $SRC/libssh2
$WGET http://www.libssh2.org/download/libssh2-1.5.0.tar.gz
tar zxvf libssh2-1.5.0.tar.gz
cd libssh2-1.5.0

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE

$MAKE LIBS="-lz -lssl -lcrypto"
make install DESTDIR=$BASE

######### ###################################################################
# ARIA2 # ###################################################################
######### ###################################################################

mkdir $SRC/aria2 && cd $SRC/aria2
$WGET http://sourceforge.net/projects/aria2/files/stable/aria2-1.19.0/aria2-1.19.0.tar.gz
tar zxvf aria2-1.19.0.tar.gz
cd aria2-1.19.0

LDFLAGS="-zmuldefs $LDFLAGS" \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--enable-libaria2 \
--enable-static \
--disable-shared \
--without-libuv \
--without-appletls \
--without-gnutls \
--without-libnettle \
--without-libgmp \
--without-libgcrypt \
--without-libexpat \
--with-xml-prefix=$DEST \
ZLIB_CFLAGS="-I$DEST/include" \
ZLIB_LIBS="-L$DEST/lib" \
OPENSSL_CFLAGS="-I$DEST/include" \
OPENSSL_LIBS="-L$DEST/lib" \
SQLITE3_CFLAGS="-I$DEST/include" \
SQLITE3_LIBS="-L$DEST/lib" \
LIBCARES_CFLAGS="-I$DEST/include" \
LIBCARES_LIBS="-L$DEST/lib" \
LIBSSH2_CFLAGS="-I$DEST/include" \
LIBSSH2_LIBS="-L$DEST/lib" \
ARIA2_STATIC=yes

$MAKE LIBS="-lz -lssl -lcrypto -lsqlite3 -lcares -lxml2 -lssh2"

make install DESTDIR=$BASE/aria2
