#!/bin/sh
#
# broadcast.sh
# ============
# This is script which broadcast with a webcam to NiconicoNamahousou.
# Sorry, this is for Linix only.
# 
# Required extra tools:
#  - ffmpeg ver.N-37669 or later (compiling with librtmp, libx264 and libfaac)
# 

SOURCEDIR=$(dirname "$0")
RTMP_URI="$1"
STREAM="$2"

if [ "${RTMP_URI}x" = "x" -o "${STREAM}x" = "x" ]; then
  if [ "${RTMP_URI}x" = "localx" ]; then
    OUTPUT_URI=test.flv
  else
    echo "Please specified RTMP_URI and STREAM."
    exit 1
  fi
fi

if [ "${OUTPUT_URI}x" = "x" ]; then
  OUTPUT_URI="${RTMP_URI}/${STREAM} 
              flashver=FME/3.0\20(compatible;\20FMSc/1.0) 
              swfUrl=${RTMP_URI}"
fi

if [ -e ${SOURCEDIR}/config ]; then  
  . ${SOURCEDIR}/config || exit 1
else
  echo "Can't open config file." >2
  exit 1
fi
if [ -e ${SOURCEDIR}/broadcast.d/${BROADCASTER} ]; then
  . ${SOURCEDIR}/broadcast.d/${BROADCASTER}
else
  echo "Can't open broadcast.d/${BROADCASTER}" >2
  exit 2
fi

# --- Muxing video/audio and sending stream to server with ffmpeg.
ffmpeg -y -stats -threads 0 \
       -f ${VIDEO_SRC_FMT} -i ${VIDEO_SRC_DEV} -bt ${VBITRATE}k \
       -f ${AUDIO_SRC_FMT} -i ${AUDIO_SRC_DEV} -ar ${ASAMPLINGRATE} \
           -ab ${ABITRATE}k -ac ${ACHANNEL} \
       ${VCODEC_OPTS} \
       ${ACODEC_OPTS} \
       ${OUTPUT_OPTS} \
       "${OUTPUT_URI}" &
wait

