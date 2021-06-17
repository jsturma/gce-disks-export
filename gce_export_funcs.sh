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
	Func_Name="$0_Delete_Image"
	args=($@)
    img_diskname=${args[0]}
  	logTime "$Func_Name - $$ - Remove image $img_diskname"
	gcloud compute images delete $img_diskname -q &> /dev/null
	rc=$? 
	if [ $rc -ne 0 ]
	then
	{
		logTime "$Func_Name - $$ - RC=$rc - Error during Image Deletion"
		exit 1
	}
	else
		logTime "$Func_Name - $$ - Image $img_diskname Deletion is complete";
	fi
		
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
	Func_Name="$0_Create_Image"
	#  $diskproject $diskregion $diskzone $instance $diskname $img_diskname 
    args=($@)
  	diskname=${args[0]}
  	diskzone=${args[1]}
    img_diskname=${args[2]}
	logTime "$Func_Name - $$ - Create new image for disk $diskname in zone $diskzone disk image name is $img_diskname"	
	gcloud compute images create $img_diskname \
		--source-disk $diskname \
	 	--source-disk-zone $diskzone \
	 	--force
	rc=$? 
	if [ $rc -ne 0 ]
	then
	{
		logTime "$Func_Name - $$ - RC=$rc - Error during Image Creation"
		exit 1
	}
	else
		logTime "$Func_Name - $$ - Image Creation is complete";
	fi
		
}

# "Disk_Project: $diskproject Disk_Region: $diskregion Disk_Zone: $diskzone Instance Name: $instance Disk: $diskname ImageDisk: $img_diskname "
export_image()
{ 
  	Func_Name="$0_Export_Image"
	##  $diskproject $diskregion $diskzone $instance $diskname $img_diskname 
    ## logTime "$Func_Name - $$ -\$@: $@"
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
	logTime "$Func_Name - $$ - Calling Export gcloud compute images export "
	logTime "$Func_Name - $$ - For Disk Image $img_diskname Export Format is '$IMAGE_FORMAT' to Cloud Storage Destination $Bucket_Uri"
	gcloud compute images export \
		--destination-uri $Bucket_Uri \
		--image $img_diskname\
		--export-format $IMAGE_FORMAT
		## Delete image after exporting
		## delete_image $diskname
	rc=$? 
	## rc=0
	if [ $rc -ne 0 ]
	then
	{
		logTime "$Func_Name - $$ - RC=$rc - Error during Export"
		exit 1
	}
	else
		logTime "$Func_Name - $$ -  Export is complete";
	fi
}

export_instance ()
{
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
  logTime "$Func_Name - $$ - Start of creating new image for disk $diskname in zone $diskzone disk image name is $img_diskname"
  echo $diskname $diskzone $img_diskname | xargs -I {} bash -c 'create_image "$@"' $Func_Name {}
  ##
  logTime "$Func_Name - $$ - Start of exporting disk image $img_diskname.$IMAGE_FORMAT to Cloud Storage Bucket: $BUCKET_NAME"
  echo $export_date $diskproject $diskregion $diskzone $instance $diskname $img_diskname $IMAGE_FORMAT $BUCKET_NAME|\
       xargs -I {} bash -c 'export_image "$@"' $Func_Name {}
  ##
  logTime "$Func_Name - $$ - Start of Deletion of disk image $img_diskname"
  echo $img_diskname| xargs -I {} bash -c 'delete_image "$@"' $Func_Name {}      
  ##
  return 0
}
