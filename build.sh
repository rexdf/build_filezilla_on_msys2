#!/bin/env sh

set -e
set -x

PRE_BUILD_PATH=$(realpath ~)/build


export PATH="${PRE_BUILD_PATH}/bin:$PATH:/mingw64/bin"


export PKG_CONFIG_PATH="${PRE_BUILD_PATH}/lib/pkgconfig"

if [ ! -d "${PRE_BUILD_PATH}" ]; then
    mkdir "${PRE_BUILD_PATH}"
fi

export EXTRA_LDFLAGS="-static-libgcc -Wl,-Bstatic -lstdc++ -lpthread -Wl,-Bdynamic"

cd ~

if true;then

tar xvaf gmp-6.0.0a.tar.xz
pushd gmp-6.0.0
./configure --host=i686-w64-mingw32 --prefix=${PRE_BUILD_PATH} --enable-static --disable-shared LDFLAGS="${EXTRA_LDFLAGS}"
make -j4
make install
popd
rm -rf gmp-6.0.0

tar xvaf nettle-2.7.1.tar.gz
pushd nettle-2.7.1
./configure --host=i686-w64-mingw32 --prefix=${PRE_BUILD_PATH} --enable-static --disable-shared --with-lib-path=${PRE_BUILD_PATH}/lib --with-include-path=${PRE_BUILD_PATH}/include LDFLAGS="${EXTRA_LDFLAGS}"
make -j4
make install
popd
rm -rf nettle-2.7.1

#git clone https://github.com/Alexpux/MINGW-packages.git
#cd MINGW-packages
#git apply ../mingw-w64-zlib.patch
#cd mingw-w64-zlib
#makepkg-mingw -sLf
tar axvf mingw-w64-i686-zlib-1.2.8-6-any.pkg.tar.xz -C build/ --transform 's,^mingw32/,./,' --strip-components=1

tar xvaf gnutls-3.3.13.tar.xz
pushd gnutls-3.3.13
./configure --host=i686-w64-mingw32 --prefix=${PRE_BUILD_PATH} --enable-static --disable-shared GMP_LIBS="-L${PRE_BUILD_PATH}/lib -lgmp" --disable-guile --disable-doc --without-p11-kit --without-tpm --disable-nls --disable-libdane --with-included-libtasn1 CPPFLAGS="-I${PRE_BUILD_PATH}/include" LDFLAGS="-L${PRE_BUILD_PATH}/lib ${EXTRA_LDFLAGS}"
make -j4
make install
popd
rm -rf gnutls-3.3.13

tar xvaf sqlite-autoconf-3080803.tar.gz
pushd sqlite-autoconf-3080803
./configure --host=i686-w64-mingw32 --prefix=${PRE_BUILD_PATH} --enable-static --disable-shared LDFLAGS="${EXTRA_LDFLAGS}"
make -j4
make install
popd
rm -rf sqlite-autoconf-3080803

tar axvf wx3.tar.xz
patch.exe -p0 < wx3_config.patch
pushd wx3
./configure --host=i686-w64-mingw32 --prefix=${PRE_BUILD_PATH} --enable-static --disable-shared --enable-unicode   --with-libjpeg=builtin --with-libpng=builtin --with-libtiff=builtin --with-expat=builtin CPPFLAGS="-I${PRE_BUILD_PATH}/include" LDFLAGS="-L${PRE_BUILD_PATH}/lib ${EXTRA_LDFLAGS}"
make -j4
make install
popd
#exit 0
rm -rf wx3

cd ~
# tar axvf filezilla.tar.xz

patch.exe -p0 < filezilla_libfilezilla_h.patch

fi

pushd filezilla
autoreconf -i
./configure --host=i686-w64-mingw32 --with-tinyxml=builtin --disable-precomp CPPFLAGS="-I${PRE_BUILD_PATH}/include" LDFLAGS="-L${PRE_BUILD_PATH}/lib ${EXTRA_LDFLAGS}"
make -j4

strip src/interface/.libs/filezilla.exe
strip src/fzshellext/32/.libs/libfzshellext-0.dll
/mingw64/bin/strip.exe src/fzshellext/64/.libs/libfzshellext-0.dll
strip src/putty/.libs/fzputtygen.exe
strip src/putty/.libs/fzsftp.exe

popd
