#!/bin/sh

##
## This script is used for packing up a video
##

./ffmpeg -y -t 15 -i asl.mov  -i logo.png -filter_complex "overlay=(main_w-overlay_w-20):(main_h-overlay_h-20)"  output.mp4
