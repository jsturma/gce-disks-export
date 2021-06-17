#!/bin/bash
##
##	echo "MIT License | Copyright (c) 2021 Jean Sturma"
##	echo "GitHub repository: https://github.com/jsturma/gce-disks-export"
##
## This software comes with ABSOLUTELY NO WARRANTY.
## This is free software, and you are welcome to redistribute it under certain conditions.
##
##
logTime()
{
    local datetime="$(date +"%Y-%m-%d %T")"
    echo -e "[$datetime]: $1"
}
