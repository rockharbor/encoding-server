#!/bin/bash

STARTTIME=$(date +"%s")

. media_common.sh

# redirect stdout and stderr to log
exec 1> >(log)
exec 2>&1

# Script triggered by `watchdog` when a file is created within a directory.
# Calls a webhook that adds the file to the WordPress media library when
# a file is completely copied / created

# import credentials
. "credentials.conf"

DIR="$1"
EVENT="$2"
SUBDOMAIN="$3"

# New storage path
STOREPATH="$4"
OUTPUT="$STOREPATH/Output"
SOURCE="$STOREPATH/Source"

# only process renamed files (the FTP system renames them
# from a temporary name to the actual name)
if [ "$EVENT" != "modified" ]; then
	exit 0
fi

# wait a random amount of seconds between 1-10
# this prevents simultaneous uploads from overlapping
sleep $[ ( $RANDOM % 30 ) + 1 ]s

# Find newest file within the directory
FILE=$(find_first_uncopied_file "$DIR" /tmp)

if [ "$FILE" = "0" ]; then
	log "$EVENT event could not find pending file in $DIR"
	exit 0
fi

log "Found valid file $FILE"

# set up naming variables
BASENAME=$(basename "$FILE")
FILENAME="${BASENAME%.*}"

log "Processing file: $FILE"

# create flag so we don't touch this file again
touch "/tmp/${BASENAME}.encoding"

# create temporary namespaced, timestamped directory
NOW=$(date +%s)
TMPFOLDER="/tmp/${SUBDOMAIN}/${NOW}"
mkdir -p "$TMPFOLDER"

# set up temp file names
TMPFILE="${TMPFOLDER}/${BASENAME}.source"
TMPVIDFILE="${TMPFOLDER}/${FILENAME}.mp4"
TMPAUDFILE="${TMPFOLDER}/${FILENAME}.mp3"

# move from uploaded location to temp
mv "$FILE" "$TMPFILE"

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
"$TMPVIDFILE" 1>/dev/null

# convert audio and save it in the output directory
ffmpeg -i "$TMPFILE" \
-acodec libmp3lame \
-b:a 128k \
-vn \
"$TMPAUDFILE" 1>/dev/null

# after converting it, copy to source path
log "Copying source to: ${SOURCE}"
cp "$TMPFILE" "${SOURCE}/${BASENAME}"

# upload video file 
curl -i -F "file=@$TMPVIDFILE" -F "username=$WP_USER" -F "password=$WP_PASSWORD" http://$SUBDOMAIN.rockharbor.org/wp-content/themes/rockharbor/upload.php 1>/dev/null

# copy to output path
cp "$TMPVIDFILE" "${OUTPUT}"

# upload audio file
curl -i -F "file=@$TMPAUDFILE" -F "username=$WP_USER" -F "password=$WP_PASSWORD" http://$SUBDOMAIN.rockharbor.org/wp-content/themes/rockharbor/upload.php 1>/dev/null

# copy to output path
cp "$TMPAUDFILE" "${OUTPUT}"

ENDTIME=$(date +"%s")
EXECTIME=$(expr $ENDTIME - $STARTTIME)

log "Processing completed (${EXECTIME}s): $FILE"

# remove flag
rm "/tmp/${BASENAME}.encoding"

exit 0
