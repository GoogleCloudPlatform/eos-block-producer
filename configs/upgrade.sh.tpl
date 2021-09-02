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


# Description: The following script runs to upgrade nodeos version of the disk. This script will be kept in crontab to run everyday.

#!/bin/bash -xe
#script checks current version of nodeos running on node and compares with Metadata. 
apt update
apt upgrade -y
metadatanodeos=${metadatanodeos}}
currentnodeos=$(nodeos --version)

if grep -q $currentnodeos <<< $metadatanodeos ; then echo "NodeOS is Upto Date"; else [

SIGN1=$(/snap/bin/gcloud compute instances list | grep sign-managed| sort | awk 'NR==2 {print $1}')

if [ $SIGN1 == $HOSTNAME ]; then
sleep 600m
fi
rm /home/gcpbp/.local/share/eosio/nodeos/data/snapshots/*
curl http://127.0.0.1:8888/v1/producer/create_snapshot | json_pp
GCL=$!
wait $GCL
sleep 10m
set +e
pkill nodeos
PKILL=$!
wait $PKILL
zone1=$(/snap/bin/gcloud compute disks list | grep $HOSTNAME |awk '{print $2}')
/snap/bin/gcloud compute disks snapshot $HOSTNAME --zone $zone1 --snapshot-names $HOSTNAME-snap
rm -r /home/gcpbp/.local/share/eosio/nodeos/data/state/
rm -r /home/gcpbp/.local/share/eosio/nodeos/data/blocks/reversible/
wget $metadatanodeos -O eosio.deb
apt install --only-upgrade ./eosio.deb
snapshotname=$(ls /home/gcpbp/.local/share/eosio/nodeos/data/snapshots)
runuser -l gcpbp -c 'tmux new-session -s gcpbp -d "nodeos --snapshots-dir /home/gcpbp/.local/share/eosio/nodeos/data/snapshots --snapshot /home/gcpbp/.local/share/eosio/nodeos/data/snapshots/$snapshotname --data-dir /home/gcpbp/.local/share/eosio/nodeos/data --config-dir /home/gcpbp/.local/share/eosio/nodeos/config|& tee -a /home/gcpbp/tmux.log"'
] ;fi