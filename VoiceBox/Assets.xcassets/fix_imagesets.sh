#!/bin/bash

for folder in *.imageset; do
  #echo "$folder"
  file_name="${folder}/Contents.json"
  file="{
    \"images\" : [
      {
        \"idiom\" : \"universal\",
        \"filename\" : \"${folder%.*}.png\"
      }
    ],
    \"info\" : {
      \"version\" : 1,
      \"author\" : \"xcode\"
    }
  }"
  echo "$file" >> "$file_name"
done
