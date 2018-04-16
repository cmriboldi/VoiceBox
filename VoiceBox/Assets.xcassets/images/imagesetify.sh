#!/usr/bin/env bash

#for img in /Users/andrewhale/Library/Developer/CoreSimulator/Devices/C897087A\-EF42\-442A\-8203\-D72F31D343F5/data/Containers/Data/Application/5E4D113F\-B6A5\-4508\-92FE\-DF594BAD1C31/Documents/images/*.png; do
#  [ -e "$img" ] || continue
#  #mv "$img" "/Users/andrewhale/Documents/CS498R/VoiceBox/VoiceBox/Assets.xcassets/images"
#  #mv "$img" "./"
#  echo "$img"
#done

for file in *.png; do
  [ -e "$file" ] || continue
  folder_name="../${file%.*}_img.imageset"
  mkdir "$folder_name"
  mv "$file" "$folder_name"

  file_name="${folder_name}/Contents.json"
  file_content="{
    \"images\" : [
      {
        \"idiom\" : \"universal\",
        \"filename\" : \"${file%.*}.png\"
      }
    ],
    \"info\" : {
      \"version\" : 1,
      \"author\" : \"xcode\"
    }
  }"
  echo "$file_content" > "$file_name"
done
