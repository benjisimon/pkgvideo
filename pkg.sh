#!/bin/sh

##
## This script is used for packing up a video
##


# Default Variables
base_dir=$(dirname $0)
font_dir=$base_dir/fonts
debug=off

ffmpeg=ffmpeg
ffprobe=ffprobe

logo=logo.png
output=output.mp4

main_video=input.mp4
main_image_x="main_w-overlay_w-20"
main_image_y="(main_h-overlay_h-40)"
main_image_w=500
main_image_h=-1
main_caption_text="Thanks for watching"
main_caption_bg_color=0xffffff@0.8
main_caption_padding=24
main_caption_x=32
main_caption_y="(h-text_h)-40-12"
main_caption_font_size=48
main_caption_font=Lato-Heavy.ttf
main_caption_color=0x222222
main_caption_start=0
main_caption_end=5

pre_duration=3
pre_image_w=500
pre_image_h=-1
pre_image_x="(main_w-overlay_w)/2"
pre_image_y="(main_h-overlay_h)*.80"
pre_bg_color=0x666666
pre_title_text="Title Text"
pre_title_font='Lato-Heavy.ttf'
pre_title_x="(w-text_w)/2"
pre_title_y="(h-text_h)/2"
pre_title_font_size=48
pre_title_color=white

pre_subtitle_text=""
pre_subtitle_font='Lato-Heavy.ttf'
pre_subtitle_x="(w-text_w)/2"
pre_subtitle_y="(h-text_h)/2"
pre_subtitle_font_size=48
pre_subtitle_color=white

post_duration=5
post_bg_color=0xE4E4E4
post_title_text="Thanks for watching"
post_title_font='Lato-Thin.ttf'
post_title_font_size=65
post_title_x="(w-text_w)/2"
post_title_y="(h-text_h)/2"
post_title_color=0x222222
post_image_w=500
post_image_h=-1
post_image_x="(main_w-overlay_w)/2"
post_image_y="(main_h-overlay_h)*.80"

config=$HOME/.pkgvid.last
cp /dev/null $config

while [ -n "$1" ] ; do
  arg=$1 ; shift
  if [ -f "$arg" ] ; then
    echo "# $arg" >> $config
    cat $arg >> $config
  fi
  
  name=$(echo $arg | cut -d= -f1)
  if [ "$name" != "$arg" ]; then
     echo $arg >> $config
  fi

  echo >> $config
done

. $config

main_video_width=$($ffprobe -show_streams $main_video 2> /dev/null |grep ^width= | cut -d = -f 2)
main_video_height=$($ffprobe -show_streams $main_video 2> /dev/null |grep ^height= | cut -d = -f 2)

if [ "$debug" = "on" ]  ; then
   ffmpeg="echo $ffmpeg"
fi

$ffmpeg -y  \
 -i $main_video \
  -i $logo  \
  -i $logo  \
  -i $logo  \
  -f lavfi -i color=color=$pre_bg_color:${main_video_width}x${main_video_height}:d=$pre_duration \
  -f lavfi -i color=color=$post_bg_color:${main_video_width}x${main_video_height}:d=$post_duration \
  -filter_complex "\
    [1:v]scale=w=$main_image_w:h=$main_image_h[logo_a] ; \
    [2:v]scale=w=$pre_image_w:h=$pre_image_h[logo_b] ; \
    [3:v]scale=w=$post_image_w:h=$post_image_h[logo_c] ; \
    [0:v][logo_a] overlay=${main_image_x}:${main_image_y} [main] ; \
    [0:a] adelay=delays=${pre_duration}000:all=1  ; \
    \
    [main]drawtext=fontfile=$font_dir/$main_caption_font: \
          text='$main_caption_text': \
          x=$main_caption_x: y=$main_caption_y: \
          fontsize=$main_caption_font_size: \
          fontcolor=$main_caption_color: \
          box=1: boxcolor=$main_caption_bg_color : line_spacing=0: \
          bordercolor=$main_caption_bg_color: borderw=0: boxborderw=$main_caption_padding: \
          enable='between(t,$main_caption_start,$main_caption_end)'[main]; \
    \
    [4:v]drawtext=fontfile=$font_dir/$pre_title_font: \
         text='$pre_title_text': \
         x='$pre_title_x': y='$pre_title_y': \
         fontsize=$pre_title_font_size: \
         fontcolor=$pre_title_color [pre]; \
    [pre]drawtext=fontfile=$font_dir/$pre_subtitle_font: \
         text='$pre_subtitle_text': \
         x='$pre_subtitle_x': y='$pre_subtitle_y': \
         fontsize=$pre_subtitle_font_size: \
         fontcolor=$pre_subtitle_color [pre]; \
    \
    [pre][logo_b] overlay=x='$pre_image_x':y='$pre_image_y' [pre] ; \
    \
    [5:v]drawtext=fontfile=$font_dir/$post_title_font: \
         text='$post_title_text':\
         x='$post_title_x': y='$post_title_y': \
        fontsize=$post_title_font_size: \
        fontcolor=$post_title_color [post]; \
    [post][logo_c] overlay=x='$post_image_x':y='$post_image_y' [post] ; \
   \
    [pre][main][post]concat=n=3 \
  " \
  -vsync 2 \
  $output
