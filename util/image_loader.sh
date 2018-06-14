#!/bin/bash

#For overriding loading and using a default value instead
if [ $1 = "-o" ]
then
  temp=$2
else
  temp=$(docker load --input $1)
fi

if [ `echo $temp | cut -d " " -f3` = "ID:" ]
then # The command outputed the image ID message, so we extract the image ID
  image_name=$(echo $temp | cut -d ":" -f3)
else # The command outputed the image tag message, so we extract the image tag
  image_name=$(echo $temp | cut -d " " -f3)
fi
echo $image_name
