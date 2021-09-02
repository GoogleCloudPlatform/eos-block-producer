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

variable "project_id" {
  type = string
}

variable "network_project_id" {
  type = string
}

variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}
variable "subnet_range" {
  default = "10.20.10.0/24"
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "nodeos_version" {
  type    = string
  default = "https://github.com/EOSIO/eos/releases/download/v2.0.9/eosio_2.0.9-1-ubuntu-18.04_amd64.deb"
}


variable "eos_web_prefix" {
  type    = string
  default = "eos-web"
}

variable "eos_web_machine_type" {
  type    = string
  default = "n2-standard-4"
}

variable "eos_web_disk_size" {
  type    = string
  default = "3072"
}

variable "eos_web_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "eos_peer_prefix" {
  type    = string
  default = "eos-peer"
}

variable "eos_peer_machine_type" {
  type    = string
  default = "n2-standard-4"
}

variable "eos_peer_disk_size" {
  type    = string
  default = "3072"
}

variable "eos_peer_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "eos_sign_prefix" {
  type    = string
  default = "eos-sign"
}

variable "eos_sign_machine_type" {
  type    = string
  default = "n2-standard-4"
}

variable "eos_sign_disk_size" {
  type    = string
  default = "3072"
}

variable "eos_sign_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "web_max_replicas" {
  description = "The maximum number of instances that the autoscaler can scale up to. This is required when creating or updating an autoscaler. The maximum number of replicas should not be lower than minimal number of replicas."
  default     = 2
}

variable "web_min_replicas" {
  description = "The minimum number of replicas that the autoscaler can scale down to. This cannot be less than 0."
  default     = 2
}

variable "web_cooldown_period" {
  description = "The number of seconds that the autoscaler should wait before it starts collecting information from a new instance."
  default     = 60
}

variable "web_autoscaling_cpu" {
  description = "Autoscaling, cpu utilization policy block as single element array. https://www.terraform.io/docs/providers/google/r/compute_autoscaler.html#cpu_utilization"
  type        = list(map(number))
  default     = []
}

variable "peer_max_replicas" {
  description = "The maximum number of instances that the autoscaler can scale up to. This is required when creating or updating an autoscaler. The maximum number of replicas should not be lower than minimal number of replicas."
  default     = 2
}

variable "peer_min_replicas" {
  description = "The minimum number of replicas that the autoscaler can scale down to. This cannot be less than 0."
  default     = 2
}

variable "peer_cooldown_period" {
  description = "The number of seconds that the autoscaler should wait before it starts collecting information from a new instance."
  default     = 60
}

variable "peer_autoscaling_cpu" {
  description = "Autoscaling, cpu utilization policy block as single element array. https://www.terraform.io/docs/providers/google/r/compute_autoscaler.html#cpu_utilization"
  type        = list(map(number))
  default     = []
}

variable "sign_max_replicas" {
  description = "The maximum number of instances that the autoscaler can scale up to. This is required when creating or updating an autoscaler. The maximum number of replicas should not be lower than minimal number of replicas."
  default     = 2
}

variable "sign_min_replicas" {
  description = "The minimum number of replicas that the autoscaler can scale down to. This cannot be less than 0."
  default     = 2
}

variable "sign_cooldown_period" {
  description = "The number of seconds that the autoscaler should wait before it starts collecting information from a new instance."
  default     = 60
}

variable "sign_autoscaling_cpu" {
  description = "Autoscaling, cpu utilization policy block as single element array. https://www.terraform.io/docs/providers/google/r/compute_autoscaler.html#cpu_utilization"
  type        = list(map(number))
  default     = []
}

variable "health_check" {
  description = "Health check to determine whether instances are responsive and able to do work"

  type = object({
    type                = string
    initial_delay_sec   = number
    check_interval_sec  = number
    healthy_threshold   = number
    timeout_sec         = number
    unhealthy_threshold = number
    response            = string
    proxy_header        = string
    port                = number
    request             = string
    request_path        = string
    host                = string
  })
  default = {
    type                = "tcp"
    initial_delay_sec   = 300
    check_interval_sec  = 30
    healthy_threshold   = 1
    timeout_sec         = 10
    unhealthy_threshold = 5
    response            = ""
    proxy_header        = "NONE"
    port                = 9876
    request             = ""
    request_path        = "/"
    host                = ""
  }
}
