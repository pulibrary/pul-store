#!/bin/bash

#
# Ingest a directory of images formatted according to our LAE specs.
#
# Usage:  lae_ingest.sh <path/to/BARCODE.jhove.xml>
#

LOG_DIR=$(readlink -f ~/lae_ingest_logs)
LOG_FILENAME="$LOG_DIR/ingest-$(date +%Y-%m-%dT%T).log"

echo ""
echo "Make sure you've started a worker! e.g.:"
echo "BACKGROUND=yes QUEUE=* rake environment resque:work"
echo ""

JHOVE_FILE=$1
if [ $JHOVE_FILE"x" == "x" ]; then
  echo "" 1>&2
  echo "Please supply the path to the JHOVE audit." 1>&2
  echo "Usage:  lae_ingest.sh <path/to/BARCODE.jhove.xml>" 1>&2
  echo "" 1>&2
  exit 64
fi

touch $LOG_FILENAME
# Call the rake task
bundle exec rake lae:ingest_box[$JHOVE_FILE] >> $LOG_FILENAME

