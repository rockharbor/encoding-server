#!/bin/bash

. media_common.sh

# Script triggered by `watchdog` when a file is created within a directory.
# Calls a webhook that adds the file to the WordPress media library when
# a file is completely copied / created

FILE="$1"
EVENT="$2"
SUBDOMAIN="$3"
WP_USERNAME="$4"
WP_PASSWORD="$5"

# only process valid files
valid_file "$FILE"

# only process new files
if [ ! -f "$FILE" -o "$EVENT" != "created" ]; then
	exit 0
fi

log "Processing file: $FILE"

wait_for_file "$FILE"

log "POSTing to WordPress"

# upload to WordPress
curl -i -F "file=@$FILE" -F "username=$WP_USERNAME" -F "password=$WP_PASSWORD" http://$SUBDOMAIN.rockharbor.org/wp-content/themes/rockharbor/upload.php

exit 0
