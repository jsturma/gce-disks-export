#!/bin/bash
##
## list_gce_vm.sh: List Google Cloud instances 
## "MIT License | Copyright (c) 2021 Jean Sturma"
## "GitHub repository: https://github.com/jsturma/gce-disks-export"
##
## This software comes with ABSOLUTELY NO WARRANTY.
## This is free software, and you are welcome to redistribute it under certain conditions.
##
Func_Name="$0.Main"
IMAGE_FORMAT=""
BUCKET_NAME="js-project-images"
Instance_Filter="metadata.items.key['export2ddve']['value']='true'"
source $PWD/tools/functions.sh
OldIFS=$IFS
##
export -f logTime
##
logTime "PID $$ - $Func_Name - Warning - Warning Work in Progress - This script is unstable "  
##
logTime "PID $$ - $Func_Name - Info - Check if Bucket $BUCKET_NAME exists"  
##
if ! gsutil ls gs://$BUCKET_NAME > /dev/null 2>&1
then
   logTime "PID $$ - $Func_Name - Error - Bucket $BUCKET_NAME not found!"
   logTime "PID $$ - $Func_Name - Error - Create a new bucket or check permissions on GCP:"
   logTime "PID $$ - $Func_Name - Error - https://console.cloud.google.com/storage/browser/"
   exit 1
else
   logTime "PID $$ - $Func_Name - Info - Bucket $BUCKET_NAME exists"
fi
##
## Set default image format if not set as argument
##
if [ -z $IMAGE_FORMAT ]
	then
		IMAGE_FORMAT="vmdk"
		logTime "PID $$ - $Func_Name - Info - Image format will be 'vmdk' as default"
	else
		# Check if supplied image format is supported
		if  [ "$IMAGE_FORMAT" == "vmdk" ] || [ "$IMAGE_FORMAT" == "vhdx" ] || [ "$IMAGE_FORMAT" == "vpc" ] || [ "$IMAGE_FORMAT" == "vdi" ] || [ "$IMAGE_FORMAT" == "qcow2" ]
			then
				logTime "PID $$ - $Func_Name - Info - Use of $IMAGE_FORMAT as image format"
			else
				logTime "PID $$ - $Func_Name - Error - Image format $IMAGE_FORMAT is not valid."
				exit 1
		fi
fi
##
## gcloud compute instances list --format="json" | jq -r '.[] | [{"\(.name)","\(.zone)", "\(.disks[].source)"}]|@text'
## gcloud compute instances list --format="json" | jq -r '.[] |.name + "," + .zone + "," + .disks[].source'
## gcloud compute instances list --filter="metadata.items.key['export2ddve']['value']='true'" --format="json"
IFS=$'\n'
logTime "PID $$ - $Func_Name - Info - Start GCP query to retrieve GCE instances list"
GCE_VM_List=$(gcloud compute instances list --filter="$Instance_Filter" --format="json" | jq -r '.[] |.name + "," + .zone + "," + .disks[].source')
if [ $? -ne 0 ]
then
   {
      logTime "PID $$ - $Func_Name - Info - RC=$? - Error during GCP Query, cannot retrieve GCE instances list"
      exit 1
   }
else
   logTime "PID $$ - $Func_Name - Info - End of GCP Query to retrieve GCE instances list";
fi
Array_GCE_VM_List=($GCE_VM_List)
##
## logTime "Number of elements in the array: ${#Array_GCE_VM_List[@]}"
##
MaxProcess=2
for line in "${Array_GCE_VM_List[@]}";
do 
   IFS=$','
   ##
   ## logTime "---- Start ----"
   ## logTime "$line"
   ## 
   Array_GCE_VM_Details=($line)
   IFS=$OldIFS
   instance=${Array_GCE_VM_Details[0]}
   diskproject=$(echo "${Array_GCE_VM_Details[2]}"| awk -F'/' '{print $7}')
   diskzone=$(echo "${Array_GCE_VM_Details[2]}"| awk -F'/' '{print $9}')
   ##
   ## length of the zone is unkonwn, let's remove the last 2 chars to get the region
   ##
   diskregion=${diskzone%??}
   diskname=$(echo "${Array_GCE_VM_Details[2]}"| awk -F'/' '{print $11}')
   img_diskname="img-"$diskname"-"$(date -d 'today' "+%s")
   export_date="$(date +%F)"
   IFS=$OldIFS
   ##
   ## logTime "Export_Date: $export_date Disk_Project: $diskproject Disk_Region: $diskregion Disk_Zone: $diskzone \
   ##          Instance Name: $instance Disk: $diskname ImageDisk: $img_diskname Bucket: $BUCKET_NAME"
   ##
   ((i=i%MaxProcess)); ((i++==0)) && wait
   ($PWD/tools/export_instance.sh $export_date $diskproject $diskregion $diskzone $instance $diskname $img_diskname $IMAGE_FORMAT $BUCKET_NAME) &  
done
# echo $values| xargs --verbose --max-procs=2 --max-args=9 -I {} bash -c '$PWD/tools/export_instance.sh "$@"' $Func_Name {}
logTime "PID $$ - $Func_Name - Info - Waiting for all export processes to finish"
wait
logTime "PID $$ - $Func_Name - Info - existing from $0 " 
IFS=$OldIFS
