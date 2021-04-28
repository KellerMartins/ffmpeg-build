#!/usr/bin/env bash

set -eu

cd $(dirname $0)
BASE_DIR=$(pwd)

source common.sh

if [ ! -e $FFMPEG_TARBALL ]
then
	curl -s -L -O $FFMPEG_TARBALL_URL
fi

: ${ARCH?}

TARGET=ffmpeg-$FFMPEG_VERSION-audio-windows-$ARCH

BUILD_DIR=$(mktemp -d -p $(pwd) build.XXXXXXXX)
trap 'rm -rf $BUILD_DIR' EXIT

cd $BUILD_DIR
tar --strip-components=1 -xf $BASE_DIR/$FFMPEG_TARBALL

FFMPEG_CONFIGURE_FLAGS+=(
    --prefix=$BASE_DIR/$TARGET
    --extra-cflags='-static -static-libgcc -static-libstdc++'
    --target-os=mingw32
    --arch=$ARCH
)

case $ARCH in
i686)
    FFMPEG_CONFIGURE_FLAGS+=(--cc="gcc -m32")
    ;;
x86_64)
    ;;
*)
    echo "Unknown architecture"
    exit 1
esac

./configure "${FFMPEG_CONFIGURE_FLAGS[@]}"
make
make install

chown $(stat -c '%u:%g' $BASE_DIR) -R $BASE_DIR/$TARGET
