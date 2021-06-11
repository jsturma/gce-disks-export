#!/bin/bash
##
## list_gce_vm.sh: List Google Cloud instances 
## "MIT License | Copyright (c) 2021 Jean Sturma"
## "GitHub repository: https://github.com/jsturma/gce-disks-export"
##
## This software comes with ABSOLUTELY NO WARRANTY.
## This is free software, and you are welcome to redistribute it under certain conditions.
IMAGE_FORMAT=""
BUCKET_NAME="js-project-images"
source $(pwd)/gce_export_funcs.sh
OldIFS=$IFS
##
##
logTime "Check if Bucket $BUCKET_NAME exists"  
if ! gsutil ls gs://$BUCKET_NAME > /dev/null 2>&1
then
   logTime "Bucket $BUCKET_NAME not found!"
   logTime "Create a new bucket or check permissions on GCP:"
   logTime "https://console.cloud.google.com/storage/browser/"
   exit 1
else
   logTime "Bucket $BUCKET_NAME exists"
fi

# Set default image format if not set as argument
if [ -z $IMAGE_FORMAT ]
	then
		IMAGE_FORMAT="vmdk"
		logTime "Image format will be 'vmdk' as default"
	else
		# Check if supplied image format is supported
		if  [ "$IMAGE_FORMAT" == "vmdk" ] || [ "$IMAGE_FORMAT" == "vhdx" ] || [ "$IMAGE_FORMAT" == "vpc" ] || [ "$IMAGE_FORMAT" == "vdi" ] || [ "$IMAGE_FORMAT" == "qcow2" ]
			then
				logTime "Use $IMAGE_FORMAT image format"
			else
				logTime "Image format $IMAGE_FORMAT is not valid."
				exit 1
		fi
fi
##
##
## gcloud compute instances list --format="json" | jq -r '.[] | [{"\(.name)","\(.zone)", "\(.disks[].source)"}]|@text'
## gcloud compute instances list --format="json" | jq -r '.[] |.name + "," + .zone + "," + .disks[].source'
IFS=$'\n'
logTime "Start GCP query to retrieve GCE instances list"
GCE_VM_List=$(gcloud compute instances list --format="json" | jq -r '.[] |.name + "," + .zone + "," + .disks[].source')
if [ $? -ne 0 ]
then
   {
      logTime "RC=$? - Error during GCP Query, cannot retrieve GCE instances list"
      exit 1
   }
else
   logTime "RC=$? - End of GCP Query to retrieve GCE instances list";
fi
Array_GCE_VM_List=($GCE_VM_List)
## logTime "Number of elements in the array: ${#Array_GCE_VM_List[@]}"
for line in "${Array_GCE_VM_List[@]}";
do 
   IFS=$','
   ## logTime "---- Start ----"
   ## logTime "$line" 
   Array_GCE_VM_Details=($line)
   IFS=$OldIFS
   instance=${Array_GCE_VM_Details[0]}
   diskproject=$(echo "${Array_GCE_VM_Details[2]}"| awk -F'/' '{print $7}')
   diskzone=$(echo "${Array_GCE_VM_Details[2]}"| awk -F'/' '{print $9}')
   # length of the zone is unkonwn, let's remove the last 2 chars to get the region
   diskregion=${diskzone%??}
   diskname=$(echo "${Array_GCE_VM_Details[2]}"| awk -F'/' '{print $11}')
   img_diskname=$diskname"-"$(date -d 'today' "+%s")
   export_date="$(date +%F)"
   logTime "Disk_Project: $diskproject Disk_Region: $diskregion Disk_Zone: $diskzone Instance Name: $instance Disk: $diskname ImageDisk: $img_diskname "
   create_image&&\
   export_image
done
IFS=$OldIFS
