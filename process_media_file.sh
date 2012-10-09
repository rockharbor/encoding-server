#!/bin/bash

STARTTIME=$(date +"%s")

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

FILEPATH=$(dirname "$FILE")

log "Processing file: $FILE"

# copy file to local disk
FILENAME=$(basename "$FILE")
FILENAMENOEXT="${FILENAME%.*}"
TMPFILE="/tmp/${FILENAME}"
cp "$FILE" "/tmp/${FILENAME}"

OUTPUT="${FILEPATH}/Output"
TMPVID="/tmp/${FILENAMENOEXT}.mp4"
TMPAUD="/tmp/${FILENAMENOEXT}.mp3"

# convert video and save it in the output directory
ffmpeg -i "$TMPFILE" \
-vcodec libx264 \
-preset fast \
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
-vn \
"$TMPAUD"

# after converting it, move source file to correct path and
# remove temporary file
log "Moving source to: ${FILEPATH}/Source"
mv -f "$FILE" "${FILEPATH}/Source"
rm "$TMPFILE"

# upload video file 
curl -i -F "file=@$TMPVID" -F "username=$WP_USER" -F "password=$WP_PASSWORD" http://$SUBDOMAIN.rockharbor.org/wp-content/themes/rockharbor/upload.php

# move to the server
mv "$TMPVID" "${OUTPUT}"

# upload audio file
curl -i -F "file=@$TMPAUD" -F "username=$WP_USER" -F "password=$WP_PASSWORD" http://$SUBDOMAIN.rockharbor.org/wp-content/themes/rockharbor/upload.php

# move to the server
mv "$TMPAUD" "${OUTPUT}"

ENDTIME=$(date +"%s")
EXECTIME=$(expr $ENDTIME - $STARTTIME)

log "Processing completed (${EXECTIME}s): $FILE"

exit 0
