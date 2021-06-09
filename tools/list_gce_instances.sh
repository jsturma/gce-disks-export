#!/bin/bash
##
## list_gce_vm.sh: List Google Cloud instances 
## "MIT License | Copyright (c) 2021 Jean Sturma"
## "GitHub repository: https://github.com/jsturma/gce-disks-export"
##
## This software comes with ABSOLUTELY NO WARRANTY.
## This is free software, and you are welcome to redistribute it under certain conditions.
OldIFS=$IFS
logTime()
{
    local datetime="$(date +"%Y-%m-%d %T")"
    echo -e "[$datetime]: $1"
}
##
## gcloud compute instances list --format="json" | jq -r '.[] | [{"\(.name)","\(.zone)", "\(.disks[].source)"}]|@text'
## gcloud compute instances list --format="json" | jq -r '.[] |.name + "," + .zone + "," + .disks[].source'
IFS=$'\n'
GCE_VM_List=$(gcloud compute instances list --format="json" | jq -r '.[] |.name + "," + .zone + "," + .disks[].source')
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
   project=$(echo "${Array_GCE_VM_Details[1]}"| awk -F'/' '{print $7}')
   zone=$(echo "${Array_GCE_VM_Details[1]}"| awk -F'/' '{print $9}')
   # length of the zone is unkonwn, let's remove the last 2 chars to get the region
   region=${zone%??}
   disk=$(echo "${Array_GCE_VM_Details[2]}"| awk -F'/' '{print $11}')
   logTime "Project: $project   Region: $region Zone: $zone Instance Name: $instance    Disk: $disk "
done
