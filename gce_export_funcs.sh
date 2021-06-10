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
	logTime "Image Creation is complete"
}

export_image()
{ 
  	logTime "Export disk image $diskname.$IMAGE_FORMAT to Cloud Storage Bucket: $BUCKET_NAME"
		## gcloud compute images export \
		## 		--destination-uri gs://$BUCKET_NAME/$diskname.$IMAGE_FORMAT \
		## 		--image $diskname \
		## 		--export-format $IMAGE_FORMAT
		## Delete image after exporting
		## delete_image $diskname
    logTime "Export is complete"
}