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
MODIFIED=$(stat -f "%c" "$FILE")
DATE=$(date -jf "%s" "$MODIFIED" +"%Y%m%d")
FILEPATH=$(dirname "$FILE")

VIDOUTPUT="${FILEPATH}/Output/${DATE}_${SUBDOMAIN}_message.mp4"
AUDOUTPUT="${FILEPATH}/Output/${DATE}_${SUBDOMAIN}_message.mp3"

log "Processing file: $FILE"

# convert video and save it in the output directory
ffmpeg -i $FILE \
-vcodec libx264 \
-preset slow \
-b:v 1200k \
-maxrate 1200k \
-bufsize 2400k \
-filter_complex pad="ih*16/9:ih:(ow-iw)/2:(oh-ih)/2" \
-aspect 16:9 \
-s 1280x720 \
-threads 0 \
-acodec libvo_aacenc \
-b:a 128k \
$VIDOUTPUT

# convert audio and save it in the output directory
ffmpeg -i $FILE \
-acodec libmp3lame \
-b:a 128k \
$AUDOUTPUT

# after converting it, move it to the source folder
log "Moving source to: ${FILEPATH}/Source"
mv -f "$FILE" "${FILEPATH}/Source/${DATE}_${SUBDOMAIN}_message.${EXT}"

exit 0
# upload video file 
curl -i -F "file=@$VIDOUTPUT" -F "username=$WP_USERNAME" -F "password=$WP_PASSWORD" http://$SUBDOMAIN.rockharbor.org/wp-content/themes/rockharbor/upload.php

# upload audio file
curl -i -F "file=@$AUDOUTPUT" -F "username=$WP_USERNAME" -F "password=$WP_PASSWORD" http://$SUBDOMAIN.rockharbor.org/wp-content/themes/rockharbor/upload.php

exit 0
