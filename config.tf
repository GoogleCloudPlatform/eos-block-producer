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
resource "random_id" "suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "eos_config" {
  project  = var.project_id
  name     = "eos-config-${random_id.suffix.hex}"
  location = var.region
}

data "template_file" "peer_config_ini" {
  template = file("${path.cwd}/configs/peer_config.ini.tpl")
  vars = {
    peer_ip_address = module.web_http_lb.external_ip
  }
}

data "template_file" "sign_config_ini" {
  template = file("${path.cwd}/configs/sign_config.ini.tpl")
  vars = {
    peer_ip_address = module.web_http_lb.external_ip
    bk_ip_address   = google_compute_global_forwarding_rule.web_tcp_fr.ip_address
  }
}

data "template_file" "web_config_ini" {
  template = file("${path.cwd}/configs/web_config.ini.tpl")
  vars = {
    peer_ip_address = module.web_http_lb.external_ip
  }
}

data "template_file" "img" {
  template = file("${path.cwd}/configs/img.sh.tpl")
}

data "template_file" "genesis" {
  template = file("${path.cwd}/configs/genesis.json.tpl")
}

data "template_file" "swap" {
  template = file("${path.cwd}/configs/swap.sh.tpl")
}

data "template_file" "upgrade" {
  template = file("${path.cwd}/configs/upgrade.sh.tpl")
  vars = {
    metadatanodeos = var.nodeos_version
  }
}

data "template_file" "keosd" {
  template = file("${path.cwd}/configs/keosd.ini.tpl")
}

# copying the config files to storage bucket

resource "google_storage_bucket_object" "peer_config_ini" {
  name    = "peer_config.ini"
  content = data.template_file.peer_config_ini.rendered
  bucket  = google_storage_bucket.eos_config.name
}

resource "google_storage_bucket_object" "sign_config_ini" {
  name    = "sign_config.ini"
  content = data.template_file.sign_config_ini.rendered
  bucket  = google_storage_bucket.eos_config.name
}

resource "google_storage_bucket_object" "web_config_ini" {
  name    = "web_config.ini"
  content = data.template_file.web_config_ini.rendered
  bucket  = google_storage_bucket.eos_config.name
}

resource "google_storage_bucket_object" "img_config_ini" {
  name    = "img.sh"
  content = data.template_file.img.rendered
  bucket  = google_storage_bucket.eos_config.name
}

resource "google_storage_bucket_object" "upgrade_config_ini" {
  name    = "upgrade.sh"
  content = data.template_file.upgrade.rendered
  bucket  = google_storage_bucket.eos_config.name
}

resource "google_storage_bucket_object" "keosd_ini" {
  name    = "keosd.ini"
  content = data.template_file.keosd.rendered
  bucket  = google_storage_bucket.eos_config.name
}

resource "google_storage_bucket_object" "genesis" {
  name    = "genesis.json"
  content = data.template_file.genesis.rendered
  bucket  = google_storage_bucket.eos_config.name
}

resource "google_storage_bucket_object" "swap_config_ini" {
  name    = "swap.sh"
  content = data.template_file.swap.rendered
  bucket  = google_storage_bucket.eos_config.name
}
