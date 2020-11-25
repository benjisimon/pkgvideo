#!/bin/sh

##
## This script is used for packing up a video
##

./ffmpeg -y  \
  -t 15 -i asl.mov \
  -i logo.png \
  -f lavfi -i color=color=0x666666:1680x1050:d=3:rate=60 \
  -filter_complex "\
    [0:v][1:v] overlay=(main_w-overlay_w-20):(main_h-overlay_h-20)[main] ;
    [main]drawtext=fontfile=./fonts/Lato-Heavy.ttf: text='www.ASLdeafined.com': x=20: y=(h-text_h-20): fontsize=48: fontcolor=0x8a2bE2: shadowcolor=black@.8: shadowx=4: shadowy=4: enable='between(t,0,5)'[main]; \
    [2:v]drawtext=fontfile=./fonts/Pacifico.ttf: text='ASLdeafined': x=(w-text_w)/2: y=h-text_h-40: fontsize=65: fontcolor=white[pre]; \
    [pre][1:v] overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2 [pre] ; \
    [pre][main]concat \
  " \
  output.mp4
