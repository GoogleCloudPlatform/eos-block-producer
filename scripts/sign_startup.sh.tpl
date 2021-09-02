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

#!/bin/bash -xe
apt-get update && apt-get upgrade -y
wget https://github.com/EOSIO/eos/releases/download/v2.0.9/eosio_2.0.9-1-ubuntu-18.04_amd64.deb -O eosio.deb
apt install ./eosio.deb
set +e
useradd -m -s /bin/bash gcpbp
runuser -l gcpbp -c 'mkdir -p ~/.local/share/eosio/nodeos/config '
runuser -l gcpbp -c 'mkdir -p ~/.local/share/eosio/nodeos/data/snapshots'
runuser -l gcpbp -c 'cd ~/.local/share/eosio/nodeos/config'
runuser -l gcpbp -c 'gsutil cp gs://${config_bucket_name}/sign_config.ini ~/.local/share/eosio/nodeos/config/config.ini'
runuser -l gcpbp -c 'gsutil cp gs://${config_bucket_name}/genesis.json ~/.local/share/eosio/nodeos/config/genesis.json'
runuser -l gcpbp -c 'tmux new-session -s gcpbp -d nodeos --config-dir ~/.local/share/eosio/nodeos/config --genesis-json /home/gcpbp/.local/share/eosio/nodeos/config/genesis.json'
runuser -l gcpbp -c 'gsutil cp gs://${config_bucket_name}/img.sh /home/gcpbp/img.sh'
chmod 755 /home/gcpbp/img.sh
runuser -l gcpbp -c 'echo "* 22 * * * /home/gcpbp/img.sh 2>&1 | logger -t imglog"  | crontab - '
gsutil cp gs://${config_bucket_name}/upgrade.sh /root/upgrade.sh'
chmod 755 /root/upgrade.sh
echo "* 08 * * * /root/upgrade.sh 2>&1 |logger -t upgradelog" | crontab -
