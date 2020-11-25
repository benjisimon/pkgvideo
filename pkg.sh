#!/bin/sh

##
## This script is used for packing up a video
##

./ffmpeg -y -t 15 -i asl.mov \
  -i logo.png -filter_complex "\
      overlay=(main_w-overlay_w-20):(main_h-overlay_h-20), \
      drawtext=fontfile=./fonts/Lato-Heavy.ttf: text='www.ASLdeafined.com': x=20: y=(h-text_h-20): fontsize=48: fontcolor=0x8a2bE2: shadowcolor=black@.8: shadowx=4: shadowy=4: enable='between(t,3,8)'\
  " output.mp4
