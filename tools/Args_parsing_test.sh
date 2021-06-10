#!/bin/bash
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
        GCP_Instance_Name="ALL"
		echo "$GCP_Instance_Name instances disks will be exported"
        shift 1
      fi
      ;;
    -d|--GCP_Instance_Disk_Name)
       if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        GCP_Instance_Disk_Name=$2
        echo "$GCP_Instance_Disk_Name disks will be exported into image format $IMAGE_FORMAT"
        shift 2
      else
        GCP_Instance_Disk_Name="ALL"
        echo "$GCP_Instance_Disk_Name disks will be exported into image format $IMAGE_FORMAT"
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
# set positional arguments in their proper place
eval set -- "$PARAMS"