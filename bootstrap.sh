#!/bin/bash
# $Id: bootstrap.sh 82 2005-08-05 23:51:50Z lennart $

# This file is part of nss-mdns.
#
# nss-mdns is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# nss-mdns is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with nss-mdns; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.

VERSION=1.9

run_versioned() {
    local P
    type -p "$1-$2" &> /dev/null && P="$1-$2" || local P="$1"

    shift 2
    "$P" "$@"
}

echo "Just run \"autoreconf\" with your favorite flags next time instead of using this script..."
if [ "x${1}" = "xam" ] ; then
    set -ex
    run_versioned automake "${VERSION}" --add-missing --copy --foreign
    ./config.status
else 
    set -ex

    test -d autom4te.cache && rm -rf autom4te.cache
    test -e config.cahce && rm -f config.cache

    run_versioned aclocal "${VERSION}" --force
    if [ -x "$(which libtoolize)" ]; then
    	libtoolize --copy --force --automake
    elif [ -x "$(which glibtoolize)" ]; then
    	glibtoolize --copy --force --automake 
    fi
    autoheader --force
    run_versioned automake "${VERSION}" --add-missing --copy --foreign
    autoconf --force -Wall

    CFLAGS="${CFLAGS} -g -O0" ./configure --sysconfdir=/etc --localstatedir=/var "$@"

    make clean
fi
