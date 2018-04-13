#!/usr/bin/env bash

for file in *.png; do
  #echo "$file"
  [ -e "$file" ] || continue
  folder_name="../${file%.*}_img.imageset"
  mkdir "$folder_name"
  mv "$file" "$folder_name"
  #echo "$folder_name"
done
