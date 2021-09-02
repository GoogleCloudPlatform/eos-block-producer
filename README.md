# EOS Block Producer
This is a Terraform module to create an EOS Block Producer (BP) node on Google Cloud Platform (GCP).

The instructions for use assume an understanding of how a BP node works, full documnetation can be found on the EOS.io website https://developers.eos.io/manuals/eos/latest/index placeholder values have been used where possible and will need to be replaced as per the instructions.

## Instructions
1. gcloud SDK installed
2. Terraform 0.13 installed
3. A GCP project (create with the command `gcloud projects create <PROJECT_NAME>`)
4. Set project as active (use the command `gcloud config set project <PROJECT_NAME>`)
<!-- 4. Enable the following APIs in the GCP project -->
5. Update EOS configuration files. Sample "config.ini" files are given which need to be updated according to the requirements. Agent name, Block producer key etc.
6. A GCS Storage bucket (create with the command `gsutil mb gs://<BUCKET_NAME>')
    - Copy the required files to this bucket with the command   `gsutil cp configs/*_config.ini.tpl gs://<BUCKET_NAME>/config_ini/`
7. Update `example.terraform.tfvars` and rename to `terraform.tfvars` variables are detailed in table below
8. Update `backend.tf` to store terraform state file in a GCS bucket
9. Run `terraform init`
10. Run `terraform plan` and review the output
11. Run `terraform apply`

## Terrform Variables
1. Update backend.tf 
Replacing bucket = "my-new-bucket" with the bucket name to save terraform state.

2. Update terraform.tfvars

|variable| value|
|------|-------|
|org_id|Organization ID|
|project_id|Project ID |
|region|Region where resources will be created. |
|subnetname| name of the subnet to be created|
|network| name of the network to be created|
|subnet| The subnet in CIDR notation for the network|
|disk_type| Disk type, either pd-standard, pd-balanced, or pd-ssd|
|disk_size| Disk size in MB|
 
 ## Resources created by the script

This terraform script will set-up Block Produer environment. It includes following list of Components.

| Component | Description | Details    |
|-----------|-------------|------------|
| sign MIG  | Managed instance group for Singing API nodes.|  Maximum 2 instances, Auto-heal|
| peer MIG  | Managed instance group for peering API nodes. |  Maximum 2 instances, Auto-heal |
| web MIG  | Managed instance group for Chain API nodes.| Maximum 2 instances, Auto-heal|
| sign instance template | Instance Template for Singing node |  n2-Standard-16 | 
| web instance template |  Instance Template for Web node (Chain API)| n2-Standard-4 |
|peer instance template |  Instance Template for Peering node|n2-Standard-8 | 
|Service Accounts | 3 service accouts are created for each type of instances. | peer service account, web service account, sign service account | 
|TCP LB | TCP Load Balancers for Peer and Chain API Nodes | 2 LB|
|HTTP LB | HTTP Load Balancers for Peer and Chain API Noes | 2 LB |
|VPC and Subnet |  Single non-default VPC with 1 subnet is created. | |
|TCP health check| TCP health check on port 8888 and 9876 |''|
|HTTP health check |HTTP health check on port 8888 |''|
|CloudNAT |  All instances only have internal IP address. Internet is accessed via CloudNAT|''|