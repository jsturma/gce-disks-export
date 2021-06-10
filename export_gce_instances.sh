#!/bin/bash
##
## list_gce_vm.sh: List Google Cloud instances 
## "MIT License | Copyright (c) 2021 Jean Sturma"
## "GitHub repository: https://github.com/jsturma/gce-disks-export"
##
## This software comes with ABSOLUTELY NO WARRANTY.
## This is free software, and you are welcome to redistribute it under certain conditions.
source $(pwd)/gce_export_funcs.sh
OldIFS=$IFS
##
## gcloud compute instances list --format="json" | jq -r '.[] | [{"\(.name)","\(.zone)", "\(.disks[].source)"}]|@text'
## gcloud compute instances list --format="json" | jq -r '.[] |.name + "," + .zone + "," + .disks[].source'
IFS=$'\n'
logTime "Start GCP query to retrieve GCE instances list"
GCE_VM_List=$(gcloud compute instances list --format="json" | jq -r '.[] |.name + "," + .zone + "," + .disks[].source')
logTime "RC=$? - End of GCP Query to retrieve GCE instances list"
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
   logTime "Disk_Project: $diskproject Disk_Region: $diskregion Disk_Zone: $diskzone Instance Name: $instance Disk: $diskname ImageDisk: $img_diskname "
   create_image
   export_image
done
IFS=$OldIFS
