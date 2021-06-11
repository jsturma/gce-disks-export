#!/bin/bash
##
##	echo "MIT License | Copyright (c) 2021 Jean Sturma"
##	echo "GitHub repository: https://github.com/jsturma/gce-disks-export"
##
## This software comes with ABSOLUTELY NO WARRANTY.
## This is free software, and you are welcome to redistribute it under certain conditions.
##
##

delete_image() {
	echo "---"
	echo "Remove image $diskname"
	gcloud compute images delete $1 -q &> /dev/null
}

##
## Create Image Function
##
logTime()
{
    local datetime="$(date +"%Y-%m-%d %T")"
    echo -e "[$datetime]: $1"
}
create_image(){ 
    logTime "Create new image for disk $diskname in zone $diskzone"	
		## gcloud compute images create $diskname \
		## 	--source-disk $diskname \
		## 	--source-disk-zone $diskzone \
		## 	--force
		## rc=$?
	rc=0 
	if [ $rc -ne 0 ]
	then
	{
		logTime "RC=$rc - Error during Image Creation"
		exit 1
	}
	else
		logTime "RC=$rc - Image Creation is complete";
	fi
		
}

# "Disk_Project: $diskproject Disk_Region: $diskregion Disk_Zone: $diskzone Instance Name: $instance Disk: $diskname ImageDisk: $img_diskname "
export_image()
{ 
  	Bucket_Uri="gs://$BUCKET_NAME/$diskproject/$diskregion/$diskzone/$export_date/$instance/$img_diskname.$IMAGE_FORMAT" 
	logTime "Export disk image $img_diskname.$IMAGE_FORMAT to Cloud Storage Bucket: $BUCKET_NAME Uri:$Bucket_Uri"
		## gcloud compute images export \
		## 		--destination-uri gs://$BUCKET_NAME/$diskname.$IMAGE_FORMAT \
		## 		--image $diskname \
		## 		--export-format $IMAGE_FORMAT
		## Delete image after exporting
		## delete_image $diskname
		## rc=$?
	rc=1 
	if [ $rc -ne 0 ]
	then
	{
		logTime "RC=$rc - Error during Export"
		exit 1
	}
	else
		logTime "RC=$rc - Export is complete";
	fi
}