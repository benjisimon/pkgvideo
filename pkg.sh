#!/bin/sh

##
## This script is used for packing up a video
##

./ffmpeg -y  \
  -t 15 -i water.mp4 \
  -i etz_logo.png \
  -f lavfi -i color=color=0x666666:1920x1080:d=3:rate=23.98 \
  -f lavfi -i color=color=0xE4E4E4:1920x1080:d=3:rate=23.98 \
  -filter_complex "\
    [1:v] scale=w=500:h=-1, split [logo_a][logo_b] ; \
    [0:v][logo_a] overlay=(main_w-overlay_w-20):(main_h-overlay_h-20)[main] ; \
    [main]drawtext=fontfile=./fonts/Lato-Heavy.ttf: text='Rav Natan Freller': x=20: y=(h-text_h-20): fontsize=48: fontcolor=0x8a2bE2: shadowcolor=black@.8: shadowx=4: shadowy=4: enable='between(t,0,5)'[main]; \
    [2:v]drawtext=fontfile=./fonts/Pacifico.ttf: text='Etz Hayim': x=(w-text_w)/2: y=h-text_h-40: fontsize=65: fontcolor=white[pre]; \
    [pre][logo_b] overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2 [pre] ; \
    [3:v]drawtext=fontfile=./fonts/Lato-Thin.ttf: text='www.etzhayim.net': x=(w-text_w)/2: y=(h-text_h)/2: fontsize=65: fontcolor=0x222222[post]; \
    [pre][main][post]concat=n=3 \
  " \
  -vsync 2 \
  output.mp4
