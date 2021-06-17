#!/bin/bash
##
##	echo "MIT License | Copyright (c) 2021 Jean Sturma"
##	echo "GitHub repository: https://github.com/jsturma/gce-disks-export"
##
## This software comes with ABSOLUTELY NO WARRANTY.
## This is free software, and you are welcome to redistribute it under certain conditions.
##
##
source $PWD/functions.sh
Func_Name="$0_Delete.Image"
if [[ $# -ne 1 ]]; then
    logTime "PID $$ - $Func_Name - Illegal number of parameters"
    logTime "PID $$ - $Func_Name - Usage: $0 ImageDiskName"
	logTime "PID $$ - $Func_Name - Requires Google SDK: gcloud, gsutil"
    exit 2
fi
args=($@)
img_diskname=${args[0]}
logTime "PID $$ - $Func_Name - Remove image $img_diskname"
gcloud compute images delete $img_diskname -q &> /dev/null
rc=$? 
if [ $rc -ne 0 ]
then
{
    logTime "PID $$ - $Func_Name - RC=$rc - Error during Image Deletion"
    exit 1
}
else
    logTime "PID $$ - $Func_Name - Image $img_diskname Deletion is complete";
fi
		