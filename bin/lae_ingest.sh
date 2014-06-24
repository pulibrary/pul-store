#!/bin/bash

#
# Ingest a directory of images formatted according to our LAE specs.
#
# Usage:  lae_ingest.sh <path/to/BARCODE.jhove.xml>
#

echo ""
echo "Make sure you've started a worker! e.g.:"
echo "BACKGROUND=yes QUEUE=* bundle exec rake environment resque:work >> log/resque.log 2>> log/resque.log"
echo ""

JHOVE_FILE=$1
if [ $JHOVE_FILE"x" == "x" ]; then
  echo "" 1>&2
  echo "Please supply the path to the JHOVE audit." 1>&2
  echo "Usage:  lae_ingest.sh <path/to/BARCODE.jhove.xml>" 1>&2
  echo "" 1>&2
  exit 64
fi

./bundle exec rake lae:ingest_box[$JHOVE_FILE]

