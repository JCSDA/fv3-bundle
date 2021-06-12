#!/bin/bash

BASE_URL=https://dashrepo.ucar.edu/api/v1/dataset/147_miesch/version/1.1.0/file

BGFILE=tutorials_Hofx-NRT_input_bg.tar.gz
OBSFILE=tutorials_Hofx-NRT_input_obs.tar.gz

mkdir -p input
cd input

if [[ ! -d bg ]]; then

   wget $BASE_URL/$BGFILE
   chksum='9112472ee6952a3cc14f36173853d3b4'
   local_chksum=$(md5sum "$BGFILE" | cut -f1 -d" ")
   if [[ $chksum != ${local_chksum} ]]; then
      echo "download failed: try again"
      rm -rf bg
      exit 0
   fi
   tar xvf $BGFILE
   rm $BGFILE

fi

if [[ ! -d obs ]]; then

   wget $BASE_URL/$OBSFILE
   chksum='36d98364320bad2cc4c0477a34d8bd0d'
   local_chksum=$(md5sum "$OBSFILE" | cut -f1 -d" ")
   if [[ $chksum != ${local_chksum} ]]; then
      echo "download failed: try again"
      rm -rf obs
      exit 0
   fi
   tar xvf $OBSFILE
   rm $OBSFILE

fi

exit 0
