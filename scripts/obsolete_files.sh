#!/bin/sh

# Copyright (c) 2015 Franco Fichtner <franco@opnsense.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

set -e

if [ ${#} -lt 2 ]; then
	echo "Usage: ${0} old.txz new.txz [old.obsolete]"
	exit 1
fi

tar -tf ${1} | sed -e 's/^\.//g' -e '/\/$/d' | sort > /tmp/setdiff.old.${$}
tar -tf ${2} | sed -e 's/^\.//g' -e '/\/$/d' | sort > /tmp/setdiff.new.${$}

: > /tmp/setdiff.tmp.${$}
if [ -n "${3}" ]; then
	# reinstated files need to be removed from old.obsolete
	diff -u ${3} /tmp/setdiff.new.${$} | grep '^-/' | \
	    cut -b 2- > /tmp/setdiff.tmp.${$}
fi

(cat /tmp/setdiff.tmp.${$}; diff -u /tmp/setdiff.old.${$} \
    /tmp/setdiff.new.${$} | grep '^-/' | cut -b 2-) | sort -u

rm -f /tmp/setdiff.*
