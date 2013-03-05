#!/bin/bash

# This file contains all common functions used by the media scripts

# Checks if we should operate on this file
function valid_file() {
	shopt -s nocasematch
	local REGEX=".\.(mp4|mov|mpg)$"
	if echo $1 | grep -Eq "$REGEX" ; then
		return 1
	else
		exit 0
	fi
}

function log() {
	local NOW=$(date)
	echo "[$NOW]: $1"
}

# checks a file until it is completely copied. OSX triggers the "created"
# event before with 0 bytes and copies one file at a time, so use -1 as
# a test to see if the bytes have changed
function wait_for_file() {
	local FILE="$1"
	if [ ! -f "$FILE" ]; then
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
