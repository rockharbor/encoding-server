#!/bin/bash

. media_common.sh

# Script triggered by `watchdog` when a file is created within a directory.
# Calls a webhook that adds the file to the WordPress media library when
# a file is completely copied / created

# import wordpress credentials
. "wordpress.conf"

FILE="$1"
EVENT="$2"
SUBDOMAIN="$3"

# only process valid files
valid_file "$FILE"

# only process new files
if [ ! -f "$FILE" -o "$EVENT" != "created" ]; then
	exit 0
fi

log "Watching file: $FILE"

wait_for_file "$FILE"

EXT=$(echo "$FILE" | awk -F . '{if (NF>1) {print $NF}}')
DATE=$(date -j -vsun +"%Y%m%d")
FILEPATH=$(dirname "$FILE")

OUTPUT="${FILEPATH}/Output"
TMPVID="/tmp/${DATE}_${SUBDOMAIN}_message.mp4"
TMPAUD="/tmp/${DATE}_${SUBDOMAIN}_message.mp3"

log "Processing file: $FILE"

# copy file to local disk
FILENAME=$(basename $FILE)
TMPFILE="/tmp/${FILENAME}"
cp "$FILE" "/tmp/${FILENAME}"

# convert video and save it in the output directory
ffmpeg -i "$TMPFILE" \
-vcodec libx264 \
-preset slow \
-b:v 1500k \
-maxrate 1500k \
-bufsize 3000k \
-filter_complex pad="ih*16/9:ih:(ow-iw)/2:(oh-ih)/2" \
-aspect 16:9 \
-s 1280x720 \
-threads 0 \
-acodec libvo_aacenc \
-b:a 128k \
"$TMPVID"

# convert audio and save it in the output directory
ffmpeg -i "$TMPFILE" \
-acodec libmp3lame \
-b:a 128k \
"$TMPAUD"

# after converting it, move source file to correct path and
# remove temporary file
log "Moving source to: ${FILEPATH}/Source"
mv -f "$FILE" "${FILEPATH}/Source/${DATE}_${SUBDOMAIN}_message.${EXT}"
rm "$TMPFILE"

# upload video file 
curl -i -F "file=@$TMPVID" -F "username=$WP_USER" -F "password=$WP_PASSWORD" http://$SUBDOMAIN.rockharbor.org/wp-content/themes/rockharbor/upload.php

# move to the server
VIDOUTPUT="${OUTPUT}/${DATE}_${SUBDOMAIN}_message.mp4"
mv "$TMPVID" "$VIDOUTPUT"

# upload audio file
curl -i -F "file=@$TMPAUD" -F "username=$WP_USER" -F "password=$WP_PASSWORD" http://$SUBDOMAIN.rockharbor.org/wp-content/themes/rockharbor/upload.php

# move to the server
AUDOUTPUT="${OUTPUT}/${DATE}_${SUBDOMAIN}_message.mp3"
mv "$TMPAUD" "$AUDOUTPUT"

exit 0
