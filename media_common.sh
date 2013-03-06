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

# checks a file until it is completely copied. OSX triggers the "created"
# event before with 0 bytes and copies one file at a time, so use -1 as
# a test to see if the bytes have changed
function wait_for_file() {
	local FILE="$1"
	if [ ! -f "$FILE" ]; then
		log "$FILE is not a file"
		exit 0
	fi
	local BYTESNOW=-1
	local BYTESLATER=$(stat -f '%z' "$FILE")
	while [ "$BYTESNOW" -ne "$BYTESLATER" ]; do
		BYTESNOW=$(stat -f '%z' "$FILE")
		sleep 60
		BYTESLATER=$(stat -f '%z' "$FILE")
	done
}
