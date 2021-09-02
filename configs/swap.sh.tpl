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


# Description: The following script runs in a VM and monitors the status of signing nodes continuously. If active node is not working , it will make passive signing node 
# as active. It runs in crontab for every minute.

#!/bin/bash -xe
set +e
signinstance1=$(/snap/bin/gcloud compute instances list | grep sign| sort | awk 'NR==1 {print $1}')
signip1=$(/snap/bin/gcloud compute instances list | grep sign| sort | awk 'NR==1 {print $4}')
signzone1=$(/snap/bin/gcloud compute instances list | grep sign| sort | awk 'NR==1 {print $2}')
signinstance2=$(/snap/bin/gcloud compute instances list | grep sign| sort | awk 'NR==2 {print $1}')
signzone2=$(/snap/bin/gcloud compute instances list | grep sign| sort | awk 'NR==2 {print $2}')
signip2=$(/snap/bin/gcloud compute instances list | grep sign| sort | awk 'NR==2 {print $4}')
touch node1-hc-0.txt node1-hc-1.txt node1-hc-2.txt node1-last-state.txt
touch node2-hc-0.txt node2-hc-1.txt node2-hc-2.txt node2-last-state.txt
for (( i=0; i<=2; i++ ))
do
rm ~/node1config.ini
rm ~/node2config.ini
lastindex=$(cat node1-last-state.txt)
if [ $lastindex -eq 0 ]
then	
   lastindex=1
elif [ $lastindex -eq 1 ]
then	
   lastindex=2
else 
   lastindex=0
fi
nc -vz $signip1 9876
if [ $? -eq 0 ]
then
echo "S" > node1-hc-$lastindex.txt
echo $i > node1-last-state.txt
else
echo "F" > node1-hc-$lastindex.txt
echo $i > node1-last-state.txt
fi
nc -vz $signip2 9876
if [ $? -eq 0 ]
then
echo "S" > node2-hc-$lastindex.txt
echo $i > node2-last-state.txt
else
echo "F" > node2-hc-$lastindex.txt
echo $i > node2-last-state.txt
fi

node1status="running"
node2status="running"
if [[ $(cat node1-hc-0.txt) == "F" && $(cat node1-hc-1.txt) == "F" && $(cat node1-hc-2.txt) == "F" ]]
then
node1status="notrunning"
rm ~/.ssh/google_compute_known_hosts
fi

if [[ $(cat node2-hc-0.txt) == "F" && $(cat node2-hc-1.txt) == "F" && $(cat node2-hc-2.txt) == "F" ]]
then
node2status="notrunning" 
rm ~/.ssh/google_compute_known_hosts
fi

nc -vz $signip1 9876
if [ $? -eq 0 ]
then
/snap/bin/gcloud compute scp --recurse --zone $signzone1 $signinstance1:/home/gcpbp/.local/share/eosio/nodeos/config/config.ini ~/node1config.ini
fi
nc -vz $signip2 9876
if [ $? -eq 0 ]
then
/snap/bin/gcloud compute scp --recurse --zone $signzone2 $signinstance2:/home/gcpbp/.local/share/eosio/nodeos/config/config.ini ~/node2config.ini
fi

test -f ~/node1config.ini 
if [ $? -eq 0 ]
then
grep '# signature-provider' ~/node1config.ini
if [ $? -eq 0 ]
then
node1="standby"
else
node1="active"
fi
else
	node1="standby"
fi

test -f ~/node2config.ini
if [ $? -eq 0 ]
then
grep '# signature-provider' ~/node2config.ini
if [ $? -eq 0 ]
then
node2="standby"
else
node2="active"
fi
else
	node2="standby"
fi

if [[ "$node1" == "active" && "$node2" == "standby" ]]
then 
     if [[ "$node1status" == "notrunning" ]]
     then
#make node 2 active        
/snap/bin/gcloud compute ssh -q $signinstance2 --zone $signzone2 --tunnel-through-iap --command "grep '# signature-provider' /home/gcpbp/.local/share/eosio/nodeos/config/config.ini && sudo sed -i 's/\# signature-provider/signature-provider/g' /home/gcpbp/.local/share/eosio/nodeos/config/config.ini && sudo pkill nodeos && sleep 5s && sudo runuser -l gcpbp -c 'tmux new-session -s gcpbp -d \"nodeos |& tee -a /home/gcpbp/tmux.log\"'"
     fi
fi
if [[ "$node1" == "standby" && "$node2" == "active" ]]
then
    if [[ "$node2status" == "notrunning" ]]
    then 
#make node 1 active
/snap/bin/gcloud compute ssh -q $signinstance1 --zone $signzone1 --tunnel-through-iap --command "grep '# signature-provider' /home/gcpbp/.local/share/eosio/nodeos/config/config.ini && sudo sed -i 's/\# signature-provider/signature-provider/g' /home/gcpbp/.local/share/eosio/nodeos/config/config.ini && sudo pkill nodeos && sleep 5s && sudo runuser -l gcpbp -c 'tmux new-session -s gcpbp -d \"nodeos |& tee -a /home/gcpbp/tmux.log\"'"
    fi 
fi
if [[ "$node1" == "active" && "$node2" == "active" ]]
then 
/snap/bin/gcloud compute ssh -q $signinstance2 --zone $signzone2 --tunnel-through-iap --command "grep '# signature-provider' /home/gcpbp/.local/share/eosio/nodeos/config/config.ini || sudo sed -i 's/signature-provider/\# signature-provider/g' /home/gcpbp/.local/share/eosio/nodeos/config/config.ini && sudo pkill nodeos && sleep 5s && sudo runuser -l gcpbp -c 'tmux new-session -s gcpbp -d \"nodeos |& tee -a /home/gcpbp/tmux.log\"'"
fi
if [[ "$node1" == "standby" && "$node2" == "standby" ]]
then
nc -vz $signip1 9876
if [ $? -eq 0 ]
then
/snap/bin/gcloud compute ssh -q $signinstance1 --zone $signzone1 --tunnel-through-iap --command "grep '# signature-provider' /home/gcpbp/.local/share/eosio/nodeos/config/config.ini && sudo sed -i 's/\# signature-provider/signature-provider/g' /home/gcpbp/.local/share/eosio/nodeos/config/config.ini && sudo pkill nodeos && sleep 5s && sudo runuser -l gcpbp -c 'tmux new-session -s gcpbp -d \"nodeos |& tee -a /home/gcpbp/tmux.log\"'"
else
/snap/bin/gcloud compute ssh -q $signinstance2 --zone $signzone2 --tunnel-through-iap --command "grep '# signature-provider' /home/gcpbp/.local/share/eosio/nodeos/config/config.ini && sudo sed -i 's/\# signature-provider/signature-provider/g' /home/gcpbp/.local/share/eosio/nodeos/config/config.ini && sudo pkill nodeos && sleep 5s && sudo runuser -l gcpbp -c 'tmux new-session -s gcpbp -d \"nodeos |& tee -a /home/gcpbp/tmux.log\"'"
	     fi		     
fi
sleep 5s
done
