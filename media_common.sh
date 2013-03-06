#!/bin/bash

# This file contains all common functions used by the media scripts

LOG=encoding.log

function log() {
	if [ -n "$1" ]; then
		IN="$1"
	else
		read IN
	fi
	local NOW=$(date)
	echo "[$NOW]: $IN" >> $LOG
}

# finds the first available file that can be encoded and is
# currently not being encoded
#
# usage:
# toencode=$(find_first_uncopied_file /path/to/files /tmp)
#
# The above example scans /path/to/files for a valid movie
# file, then checks /tmp to make sure the filename with the
# '.encoding' flag is not found
function find_first_uncopied_file() {
	local SOURCEDIR="$1"
	if [ ! -d $SOURCEDIR ]; then
		SOURCEDIR=$(dirname "$SOURCEDIR")
	fi
	local CHECKDIR="$2"
	local VALIDFILES=$(find "$SOURCEDIR" -type f -name "*.mov" -or -name "*.mp4" -or -name "*.mpg")
	for FILE in $VALIDFILES; do
		local BASENAME=$(basename "$FILE")
		if [ ! -f "${CHECKDIR}/$BASENAME.encoding" ]; then
			echo "$FILE"
			return 0
		else
			log "$FILE is already encoding"
		fi	
	done
	echo "0"
}

