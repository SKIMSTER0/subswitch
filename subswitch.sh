#!/bin/bash
#convert media files from japanese image-based subs to english using ffmpeg

#selected movie to stream
videoInput="$1"
#name of output stream (with container extension)
videoOutput="$2"
#extract extensions from destination file name
containerOutput="${videoOutput#*.}"

#extract format of video/audio streams
videoFormat=$(mediainfo --Inform="Video;%Format%\n" "$videoInput")
audioFormat=$(mediainfo --Inform="Audio;%Format%\n" "$videoInput")
textFormat=$(mediainfo --Inform="Text;%Format%\n" "$videoInput")

#check if video/audio format valid for vlc http streaming

#if [["$videoFormat" == "HEVC" ||
#    "$videoFormat" == "theora" ||
#    "$audioFormat" == "a52" ]]
#  then echo ""
#fi

#select correct english subtitle ID
#every line cooresponds to ID of subtitle stream language
#if first 'English' on second line, subtitle overlay should specify ID 1
textLangs=$(mediainfo --Inform="Text;%Language/String%\n" "$videoInput" | sed '/^*$/d')
textID=$(echo "$textLangs" | grep "English" --max-count=1 -n | grep [0-9] -o)
((textID -= 1))

#format of destination file
textOverlay=$"-filter_complex [0:v][0:s:$textID] overlay[v] -map [v]"

textMap="0:s:$textID"
audioMap='0:m:language:Jpn?'
videoMap='0:v'
videoCodec='AVC'
audioCodec='AAC'

echo $textOverlay
echo $audioMap
echo $videoCodec
echo $audioCodec
echo $videoOutput

#check if subtitle format valid for vlc http streaming
#if image-based subtitle format found, overlay subtitle onto video
if echo "$textFormat" | grep -q "PGS\|DVB\|DVD\|VOB"
  then ffmpeg -i "$videoInput" -map $textOverlay -map "$audioMap" -c:v "$videoCodec" -c:a "$audioCodec" "$videoOutput" -hide_banner
elif echo "$textFormat" | grep -q "ASS\|SRT"
  then ffmpeg -i "$videoInput" -map "$textMap" -map "$audioMap" -map "$videoMap" -c:v "$videoCodec" -c:a "$audioCodec" "$videoOutput" -hide_banner
fi
