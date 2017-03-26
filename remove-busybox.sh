#!/bin/sh

if [ $ENVIRONMENT_TYPE == "PROD" ]; then
  apk del apk-tools
  rm -f /usr/bin/pkgconf /usr/bin/pkg-config /usr/share/aclocal/pkg.m4 /usr/lib/libpkgconf.so.2 /usr/lib/libpkgconf.so.2.0.0
  rm /tmp/remove-busybox.sh
  rm -f /bin/busybox
fi
