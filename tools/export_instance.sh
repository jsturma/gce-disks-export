#!/bin/bash
##
##	echo "MIT License | Copyright (c) 2021 Jean Sturma"
##	echo "GitHub repository: https://github.com/jsturma/gce-disks-export"
##
## This software comes with ABSOLUTELY NO WARRANTY.
## This is free software, and you are welcome to redistribute it under certain conditions.
##
##
Func_Name="$0_Export_Instance"  
## $diskproject $diskregion $diskzone $instance $diskname $img_diskname 
## echo "\$0 = $0"
## echo "\$$ = $$"
## echo "\$* = $*"
# logTime "$Func_Name - $$ - \$@ = $@"
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
## echo $export_date $diskproject $diskregion $diskzone $instance $diskname $img_diskname $IMAGE_FORMAT $BUCKET_NAME
## logTime $export_date $diskproject $diskregion $diskzone $instance $diskname $img_diskname 
logTime "PID $$ - $Func_Name - Start of creating new image for disk $diskname in zone $diskzone disk image name is $img_diskname"
## echo $diskname $diskzone $img_diskname | xargs -I {} bash -c 'create_image "$@"' $Func_Name {}
##
sleep $(( $RANDOM % 10 ))
logTime "PID $$ - $Func_Name - Start of exporting disk image $img_diskname in $IMAGE_FORMAT format to Cloud Storage Bucket: $BUCKET_NAME"
## echo $export_date $diskproject $diskregion $diskzone $instance $diskname $img_diskname $IMAGE_FORMAT $BUCKET_NAME|\
##	xargs -I {} bash -c 'export_image "$@"' $Func_Name {}
##
sleep $(( $RANDOM % 10 ))
logTime "PID $$ - $Func_Name - Start of Deletion of disk image $img_diskname"
## echo $img_diskname| xargs -I {} bash -c 'delete_image "$@"' $Func_Name {}      
##
sleep $(( $RANDOM % 10 ))
