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
## Export Image Shell
##
# "Disk_Project: $diskproject Disk_Region: $diskregion Disk_Zone: $diskzone Instance Name: $instance Disk: $diskname ImageDisk: $img_diskname "
source $PWD/functions.sh
Func_Name="$0_Export.Image"
if [[ $# -ne 1 ]]; then
    logTime "PID $$ - $Func_Name - Error - Illegal number of parameters"
    logTime "PID $$ - $Func_Name - Error - Usage: $0 ExportDate DiskProject DiskRegion DiskZone InstanceName DiskName ImageDiskName ImageFormat BucketName"
	logTime "PID $$ - $Func_Name - Error - Supported image formats: vmdk (default), vhdx, vpc, vdi, and qcow2"
	logTime "PID $$ - $Func_Name - Error - Requires Google SDK: gcloud, gsutil"
    exit 2
fi

Bucket_Uri=""
args=($@)
export_date=${args[0]}
diskproject=${args[1]}
diskregion=${args[2]}
diskzone=${args[3]}
instance=${args[4]}
diskname=${args[5]}
img_diskname=${args[6]}
IMAGE_FORMAT=${args[7]}
BUCKET_NAME=${args[8]}
Bucket_Uri="gs://$BUCKET_NAME/$diskproject/$diskregion/$diskzone/$export_date/$instance/$img_diskname.$IMAGE_FORMAT" 
logTime "PID $$ - $Func_Name - Calling Export gcloud compute images export "
logTime "PID $$ - $Func_Name - For Disk Image $img_diskname Export Format is '$IMAGE_FORMAT' to Cloud Storage Destination $Bucket_Uri"
gcloud compute images export \
    --destination-uri $Bucket_Uri \
    --image $img_diskname\
    --export-format $IMAGE_FORMAT
rc=$? 
if [ $rc -ne 0 ]
then
{
    logTime "PID $$ - $Func_Name - RC=$rc - Error during Export"
    exit 1
}
else
    logTime "PID $$ - $Func_Name - Export is complete";
fi
