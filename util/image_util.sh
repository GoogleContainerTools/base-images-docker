#!/bin/bash

reset_cmd() {
    local original_image_name=$1
    local container_id=$2
    local output_image_name=$3

    local old_cmd
    old_cmd=$(docker inspect -f "{{.Config.Cmd}}" "${original_image_name}")
    # If CMD wasn't set, set it to a sane default.
    if [ "$old_cmd" = "[]" ];
    then
        old_cmd=["/bin/sh"]
    fi

    docker commit -c "CMD $old_cmd" "${container_id}" "${output_image_name}"
}
