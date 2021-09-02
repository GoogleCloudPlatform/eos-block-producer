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

# Description: The following script runs takes backup of the nodes disk . This script will be kept in crontab to run everyday.


#!/bin/bash -xe
SIGN1=$(/snap/bin/gcloud compute instances list | grep sign-managed| sort | awk 'NR==1 {print $1}')

if [ $SIGN1 == $HOSTNAME ]; then

/snap/bin/gcloud beta compute instance-groups managed update --clear-autohealing sign-managed-instance-mig --region=us-central1

sleep 2m

if pgrep nodeos; then pkill nodeos; fi
PKILL=$!
wait $PKILL
if pgrep tmux; then pkill tmux; fi
set +e
/snap/bin/gcloud beta compute machine-images delete bpmachineimage -q
sleep 2m
zone1=$(/snap/bin/gcloud compute disks list | grep $HOSTNAME |awk '{print $2}')
/snap/bin/gcloud beta compute machine-images create bpmachineimage --source-instance $HOSTNAME --source-instance-zone $zone1
GCL=$!
wait $GCL && echo "waiting for machine image to create"

echo "machine image created"
grep '# signature-provider' /home/gcpbp/.local/share/eosio/nodeos/config/config.ini || sed -i 's/signature-provider/\# signature-provider/g' /home/gcpbp/.local/share/eosio/nodeos/config/config.ini
tmux new-session -s gcpbp -d 'nodeos --data-dir /home/gcpbp/.local/share/eosio/nodeos/data --config-dir /home/gcpbp/.local/share/eosio/nodeos/config |& tee -a /home/gcpbp/tmux.log'
/snap/bin/gcloud compute snapshots delete bpmachine -q
/snap/bin/gcloud beta compute instances create bpmachine --zone $zone1 --source-machine-image bpmachineimage
sleep 15m
/snap/bin/gcloud compute instances stop bpmachine --zone $zone1
sleep 2m
/snap/bin/gcloud compute disks snapshot bpmachine --zone $zone1 --snapshot-names bpmachine

GCL=$!
wait $GCL && echo "waiting for snapshot to finish"

echo "snapshot created"


set +e
/snap/bin/gcloud compute images delete bpnodex -q
/snap/bin/gcloud compute images create bpnodex --source-image bpnode --family bpnode
/snap/bin/gcloud compute images delete bpnode -q
/snap/bin/gcloud compute images create bpnode --source-snapshot bpmachine --family bpnode
/snap/bin/gcloud compute instances delete bpmachine --zone $zone1 -q

sleep 2m
/snap/bin/gcloud beta compute instance-groups managed update sign-managed-instance-mig --health-check=tcp-health-check --region=us-central1
else echo "Hostname not same"; fi