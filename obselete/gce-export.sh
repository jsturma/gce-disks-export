#!/bin/bash
##
## gce-disks-export: Export Google Cloud instances disks to Cloud Storage
## MIT License | Copyright (c) 2019 Fabio Ferrari
## GitHub repository: https://github.com/fabio-particles/gce-disks-export
##
## This software comes with ABSOLUTELY NO WARRANTY.
## This is free software, and you are welcome to redistribute it under certain conditions.
## More info about me visit: https//particles.io
##
##	echo "MIT License | Copyright (c) 2021 Jean Sturma"
##	echo "GitHub repository: https://github.com/jsturma/gce-disks-export"
##
## This software comes with ABSOLUTELY NO WARRANTY.
## This is free software, and you are welcome to redistribute it under certain conditions.
##
## ./gce-export [GCP_Project] [GCP_Zone] [GCP_Region] [GCP_Instance_Name] [GCP_Instance_Disk_Name] BUCKET_NAME [IMAGE_FORMAT]
##
GCE_DISKS=$(gcloud compute disks list | awk '{print $1}' | sed -n '2,$p')
BUCKET_NAME=$1
IMAGE_FORMAT=$2

usage() {
	echo "Usage: gcp-export [GCP_Project] [GCP_Zone] [GCP_Region] [GCP_Instance_Name] [GCP_Instance_Disk_Name] BUCKET_NAME [IMAGE_FORMAT]"
	echo "Supported image formats: vmdk (default), vhdx, vpc, vdi, and qcow2"
	echo "Requires Google SDK: gcloud, gsutil and jq"
}


delete_image() {
	echo "---"
	echo "Remove image $diskname"
	gcloud compute images delete $1 -q &> /dev/null
}

if [ $# -eq 0 ]
	then
		usage
		echo "No arguments supplied"
		exit 1
fi
### Args Parsing
##
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -b|--BucketName)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        BUCKET_NAME=$2
        echo "Exporting to GCS Bucket $BUCKET_NAME"
        shift 2
      else
        echo "Error: Argument for $1 is missing" 
        exit 1
      fi
      ;;
    -i|--ImageFormat)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        IMAGE_FORMAT=$2
        echo "will use $IMAGE_FORMAT as image format"
        shift 2
      else
        IMAGE_FORMAT="vmdk"
		echo "Image export format will be: $IMAGE_FORMAT"
        shift 1
      fi
      ;;
    -p|--GCP_Project)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        GCP_Project=$2
        echo $GCP_Project
        shift 2
      else
        GCP_Project=$(gcloud config list --format=json| jq -r '.[] | .project|@text')
        echo "Curren GCP project $GCP_Project"
        shift 1
      fi
      ;;
    -v|--GCP_Instance_Name)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        GCP_Instance_Name=$2
        echo "$GCP_Instance_Name disks will be exported into image format $IMAGE_FORMAT"
        shift 2
      else
        GCP_Instance_Name=""
		echo "All instances disks will be exported"
        shift 1
      fi
      ;;
    -d|--GCP_Instance_Disk_Name)
       if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        GCP_Instance_Disk_Name=$2
        echo "$GCP_Instance_Disk_Name disks will be exported into image format $IMAGE_FORMAT"
        shift 2
      else
        GCP_Instance_Disk_Name=""
        echo "All disks will be exported into image format $IMAGE_FORMAT"
        shift 1
      fi
      ;;
    -r|--GCP_Region)
       if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        GCP_Region=$2
        echo $GCP_Region
        shift 2
      else
        GCP_Region=""
        echo "Ignoring argument '$1', no default GCP Region will be used"
        shift 1
      fi
      ;;
    -z|--GCP_Zone)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        GCP_Zone=$2
        echo $GCP_Zone
        shift 2
      else
        GCP_Zone=""
        echo "Ignoring argument '$1', no default GCP Zone will be used"
        shift 1
      fi
      ;;
    ## 
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
## set positional arguments in their proper place
eval set -- "$PARAMS"
##
# Set default image format if not set as argument
if [ -z $IMAGE_FORMAT ]
	then
		IMAGE_FORMAT="vmdk"
		echo "No image format set, use vmdk as default format"
	else
		# Check if supplied image format is supported
		if  [ "$IMAGE_FORMAT" == "vmdk" ] || [ "$IMAGE_FORMAT" == "vhdx" ] || [ "$IMAGE_FORMAT" == "vpc" ] || [ "$IMAGE_FORMAT" == "vdi" ] || [ "$IMAGE_FORMAT" == "qcow2" ]
			then
				echo "Use $IMAGE_FORMAT image format"
			else
				usage
				echo "Image format $IMAGE_FORMAT is not valid."
				exit 1
		fi
fi

if [ -z $GCP_Instance_Disk_Name ]
	##
	## INTERACTIVE DISKS LIST
	##
	disk_num=0
	echo "[0] All Disks"
	for diskname in $GCE_DISKS
		do
			disk_num=$((disk_num+1))
			echo "[$disk_num] $diskname"
	done

	printf 'Select disk number to export, 0 for all disks: '
	read -r selected_disk_num

	if [ $selected_disk_num -eq 0 ]
		then
			echo "Selected All disks"
		else
			selected_disk_num=$((selected_disk_num+1))
			GCE_DISKS=$(gcloud compute disks list | awk '{print $1}' |  sed -n "${selected_disk_num}p")
			if [ -z "$GCE_DISKS" ]
				then
					echo "No disk found!"
					exit 1
			fi
			echo "Selected disk: $GCE_DISKS"
	fi
else

fi
##
## EXPORT PROCEDURE
##
for diskname in $GCE_DISKS
	do
		echo "---"
		echo "Exporting Image $diskimage"
		## Delete image if exists
		## delete_image "$diskname"
		# Get disk zone
		diskzone="$(gcloud compute disks list | egrep -w "^$diskname " | awk '{print $2}')"
		echo "---"
		echo "Create new image for disk $diskname in zone $diskzone"
		gcloud compute images create $diskname \
			--source-disk $diskname \
			--source-disk-zone $diskzone \
			--force
		echo "---"
		echo "Export disk image $diskname.$IMAGE_FORMAT to Cloud Storage Bucket: $BUCKET_NAME"
		# gcloud alpha compute images export \
		gcloud compute images export \
				--destination-uri gs://$BUCKET_NAME/$diskname.$IMAGE_FORMAT \
				--image $diskname \
				--export-format $IMAGE_FORMAT
		# Delete image after exporting
		delete_image $diskname
done

echo "Export is complete"
