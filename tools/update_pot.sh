#!/bin/sh
#
# Copyright (c) 2021 Danilo G. Baio <dbaio@FreeBSD.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


ALL_RESOURCES="documentation/content/en
shared/en
website/content/en"

RESOURCES="${1:-$ALL_RESOURCES}"


for resource in $RESOURCES; do

	if [ ! -d "$resource" ]; then
		echo "Directory '$resource' not found."
		exit 1
	fi

	for document in $(find "$resource/" -name "*.adoc" ); do
		name=$(basename -s .adoc "$document")
		dirbase=$(dirname "$document")
		dir=$(echo "$dirbase" | rev | cut -d '/' -f 1 | rev)
		echo "$document"

		if [ -f "$dirbase/$name.pot" ]; then
			po4a-updatepo \
				--format asciidoc \
				--master "$document" \
				--master-charset "UTF-8" \
				--copyright-holder "The FreeBSD Project" \
				--package-name "FreeBSD Documentation" \
				--po "$dirbase/$name.pot"
			if [ -f "$dirbase/$name.pot~" ]; then
				rm -f "$dirbase/$name.pot~" 
			fi
		else
			po4a-gettextize \
				--format asciidoc \
				--master "$document" \
				--master-charset "UTF-8" \
				--copyright-holder "The FreeBSD Project" \
				--package-name "FreeBSD Documentation" \
				--po "$dirbase/$name.pot"
		fi
	done
done

