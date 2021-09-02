# Copyright 2021 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

project_id         = "Project_ID"             # Project ID
network_project_id = "Project_ID"             # same as project_id unless using a Shared VPC Network
network_name       = "network"                # A name for the network, use of the default network is not recommended
subnet_name        = "subnet"                 # A name for the subnetwork, use of the default subnet is not recommended
subnet_range       = "10.0.0.0/20"            # A range for the subnet
region             = "australia-southeast1"   # used for GCS Bucket location, and Network
zone               = "australia-southeast1-a" # used for GCE instances