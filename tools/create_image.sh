#!/bin/bash
##
##	echo "MIT License | Copyright (c) 2021 Jean Sturma"
##	echo "GitHub repository: https://github.com/jsturma/gce-disks-export"
##
## This software comes with ABSOLUTELY NO WARRANTY.
## This is free software, and you are welcome to redistribute it under certain conditions.
##
##
##
## Create Image Shell
##
source $PWD/functions.sh
Func_Name="$0_Create.Image"
if [[ $# -ne 1 ]]; then
    logTime "PID $$ - $Func_Name - Error - Illegal number of parameters"
    logTime "PID $$ - $Func_Name - Usage: $0  DiskName DiskZone ImageDiskName"
	logTime "PID $$ - $Func_Name - Requires Google SDK: gcloud, gsutil"
    exit 2
fi
#  $diskproject $diskregion $diskzone $instance $diskname $img_diskname 
args=($@)
diskname=${args[0]}
diskzone=${args[1]}
img_diskname=${args[2]}
logTime "PID $$ - $Func_Name - Create new image for disk $diskname in zone $diskzone disk image name is $img_diskname"	
gcloud compute images create $img_diskname \
    --source-disk $diskname \
    --source-disk-zone $diskzone \
    --force
rc=$? 
if [ $rc -ne 0 ]
then
{
    logTime "PID $$ - $Func_Name - RC=$rc - Error during Image Creation"
    exit 1
}
else
    logTime "PID $$ - $Func_Name - Image Creation is complete";
fi
    
