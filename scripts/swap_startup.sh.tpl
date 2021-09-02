# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Script Name:sign_startup.sh
# Author : Rakesh Kumar Reddy Arava
# Date : 2nd August 2021
# Description: The following script runs at the starting of failover monitoring VM. This script copies swap.sh file and keeps it in crontab. 
#             Swap.sh file continously monitors the signing nodes and do failover ,incase the active node fails.  
#
#!/bin/bash -xe
set +e
apt-get update && apt-get upgrade -y
gsutil cp gs://${config_bucket_name}/swap.sh /root/swap.sh
chmod +x /root/swap.sh
echo "* * * * * /root/swap.sh 2>&1 | logger -t swaplog"  | crontab -