#!/bin/bash

. media_common.sh

FILE="$1"
EVENT="$2"
SUBDOMAIN="$3"

# only process valid files
valid_file "$FILE"

# only process new files
if [ ! -f "$FILE" -o "$EVENT" != "created" ]; then
	exit 0
fi
wait_for_file "$FILE"

EXT=$(echo "$FILE" | awk -F . '{if (NF>1) {print $NF}}')
MODIFIED=$(stat -f "%c" "$FILE")
DATE=$(date -jf "%s" "$MODIFIED" +"%Y%m%d")
FILEPATH=$(dirname "$FILE")

log "Moving file: $FILE ${FILEPATH}/Compressed/${DATE}_${SUBDOMAIN}_message.${EXT}"

mv -f "$FILE" "${FILEPATH}/Compressed/${DATE}_${SUBDOMAIN}_message.${EXT}"

exit 0
