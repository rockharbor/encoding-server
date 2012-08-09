#!/bin/bash

# This file contains all common functions used by the media scripts

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
