#!/bin/bash

#
# Ingest a directory of images formatted according to our LAE specs.
#
# Usage:  lae_ingest.sh <path/to/BARCODE.jhove.xml>
#

echo ""
echo "Don't use this! Instead, from /opt/pul-store/current/bin,"
echo "start a worker (if necessary):"
echo "BACKGROUND=yes QUEUE=* ./bundle exec rake environment resque:work >> ../log/resque.log 2>> ../log/resque.log"
echo "and then run the rake task that does the ingest. You should put it in the background:"
echo "./bundle exec rake lae:ingest_box[$JHOVE_FILE] &"
echo ""

# JHOVE_FILE=$1
# if [ $JHOVE_FILE"x" == "x" ]; then
#   echo "" 1>&2
#   echo "Please supply the path to the JHOVE audit." 1>&2
#   echo "Usage:  lae_ingest.sh <path/to/BARCODE.jhove.xml>" 1>&2
#   echo "" 1>&2
#   exit 64
# fi

# ./bundle exec rake lae:ingest_box[$JHOVE_FILE]

