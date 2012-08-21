#!/bin/bash

# This file contains all common functions used by the media scripts

# Checks if we should operate on this file
function valid_file() {
	shopt -s nocasematch
	REGEX=".\.(mp4|mp3|mov)$"
	if echo $1 | grep -Eq "$REGEX" ; then
		return 1
	else
		exit 0
	fi
}

function log() {
	NOW=$(date)
	echo "[$NOW]: $1"
}

# checks a file until it is completely copied. OSX triggers the "created"
# event before with 0 bytes and copies one file at a time, so use -1 as
# a test to see if the bytes have changed
function wait_for_file() {
	FILE="$1"
	BYTESNOW=-1
	BYTESLATER=$(stat -f '%z' "$FILE")
	while [ "$BYTESNOW" -ne "$BYTESLATER" ]; do
		BYTESNOW=$(stat -f '%z' "$FILE")
		sleep 10
		BYTESLATER=$(stat -f '%z' "$FILE")
	done
}
