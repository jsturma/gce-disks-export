# Under Contruction
# Export Google Compute Engine Image - Command Line Tool
 
Export Google Cloud instances disks in your favorite format and store in [Cloud Storage](https://cloud.google.com/storage/).
Supported image formats are `vmdk` (default), `vhdx`, `vpc`, `vdi`, and `qcow2`.

## How script works,for each instance 

1. Selects automatically all disks on your current/specified Google Project   
2. Creates a new image for each selected disk
3. Stores all images in a Google Storage bucket
4. Removes all images from Google Cloud 

You can run the script from your **bash console** or from [Google Cloud Shell](https://cloud.google.com/shell/docs/quickstart).
You need login in **Google Cloud SDK** before running script, for a fast execution run it in **Cloud Shell**

Script will not ask you disk to export, if you want to export all available disks.

## Requirements

- [Google Cloud SDK](https://cloud.google.com/sdk/)
  - gcloud
  - gsutil
  - Bash CLI
  - JQ parser

## Export disks

Before running the script create a **new bucket on Google Storage**, make sure you have set right permissions on bucket.

```
$ ./gce-export [GCP_Project] [GCP_Zone] [GCP_Region] [GCP_Instance_Name] [GCP_Instance_Disk_Name] BUCKET_NAME [IMAGE_FORMAT]

# Without format, use vmdk as default
$ ./gce-export my-bucket-name

# Export as qcow2 image format
$ ./gce-export my-bucket-name qcow2
``` 

#### Cloud Build Activation

Image export requires [Cloud Build API](https://console.cloud.google.com/cloud-build/builds) activation, if you haven’t already done, script will ask you to activate it.

```
The "cloudbuild.googleapis.com" service is not enabled for this
project. It is required for this operation.
Would you like to enable this service? (Y/n)?  y
```

You must enable permission to Cloud Build service account, answer _yes_ to the next prompt:

```
The following IAM permissions are needed for this operation:
[roles/iam.serviceAccountTokenCreator
serviceAccount:347021062934@cloudbuild.gserviceaccount.com
roles/compute.admin
serviceAccount:347021062934@cloudbuild.gserviceaccount.com
roles/iam.serviceAccountUser
serviceAccount:347021062934@cloudbuild.gserviceaccount.com]

Would you like to add the permissions (Y/n)?  y
```

## Google Storage

Based on Storage class of your bucket and your images access requirements, you can save monthly cost. 

Available Cloud Storage classes:

- Multi-Regional
- Regional
- Nearline
- Coldline

### Multi-Regional Storage
- \> 99.99% typical monthly availability
- Geo-redundant
- Storing data that is frequently accessed
- Data stored in dual-regional locations


### Regional Storage
- 99.99% typical monthly availability
- Data stored in a narrow geographic region
- Storing frequently accessed data in the same region

### Nearline Storage
- 99.95% and 99.9%, typical monthly availability in multi-regional and regional
- Very low cost per GB stored
- Data you do not expect to access frequently (i.e., no more than once per month)

### Coldline
- 99.95% and 99.9%, typical monthly availability in multi-regional and regional
- Lowest cost per GB stored
- Data retrieval costs
- Higher per-operation costs
- 90-day minimum storage duration
- Data you expect to access infrequently (i.e., no more than once per year)

### Pricing 
- look into https://cloud.google.com/storage/pricing

## License
MIT
