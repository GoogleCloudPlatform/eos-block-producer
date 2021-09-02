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

data "template_file" "web_instance_startup_script" {
  template = file("${path.cwd}/scripts/web_startup.sh.tpl")
  vars = {
    config_bucket_name = google_storage_bucket.eos_config.name
  }
}

data "template_file" "peer_instance_startup_script" {
  template = file("${path.cwd}/scripts/peer_startup.sh.tpl")
  vars = {
    config_bucket_name = google_storage_bucket.eos_config.name
  }
}

data "template_file" "sign_instance_startup_script" {
  template = file("${path.cwd}/scripts/sign_startup.sh.tpl")
  vars = {
    config_bucket_name = google_storage_bucket.eos_config.name
  }
}

data "template_file" "swap_instance_startup_script" {
  template = file("${path.cwd}/scripts/swap_startup.sh.tpl")
  vars = {
    config_bucket_name = google_storage_bucket.eos_config.name
  }
}

resource "google_service_account" "eos_web" {
  project    = var.project_id
  account_id = "eos-web-sa"
}

resource "google_service_account" "eos_peer" {
  project    = var.project_id
  account_id = "eos-peer-sa"
}

resource "google_service_account" "eos_sign" {
  project    = var.project_id
  account_id = "eos-sign-sa"
}
module "project_iam_bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  version  = "~> 6.3.1"
  projects = [var.project_id]
  mode     = "additive"

  bindings = {
    "roles/compute.admin" = [
      "serviceAccount:eos-web-sa@${var.project_id}.iam.gserviceaccount.com",
      "serviceAccount:eos-peer-sa@${var.project_id}.iam.gserviceaccount.com",
      "serviceAccount:eos-sign-sa@${var.project_id}.iam.gserviceaccount.com",
    ]
    "roles/storage.objectViewer" = [
      "serviceAccount:eos-web-sa@${var.project_id}.iam.gserviceaccount.com",
      "serviceAccount:eos-peer-sa@${var.project_id}.iam.gserviceaccount.com",
      "serviceAccount:eos-sign-sa@${var.project_id}.iam.gserviceaccount.com",
    ]
    "roles/iam.serviceAccountUser" = [
      "serviceAccount:eos-sign-sa@${var.project_id}.iam.gserviceaccount.com",
    ]
    "roles/iap.tunnelResourceAccessor" = [
      "serviceAccount:eos-sign-sa@${var.project_id}.iam.gserviceaccount.com",
    ]
  }

  depends_on = [google_service_account.eos_web, google_service_account.eos_peer, google_service_account.eos_sign]
}
# creates VPC and Subnetwork
module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 3.0"
  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"
  subnets = [
    {
      subnet_name   = var.subnet_name
      subnet_ip     = var.subnet_range
      subnet_region = var.region
    }
  ]
  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
}


# Allow http
resource "google_compute_firewall" "allow-http" {
  project = var.project_id
  name    = "fw-allow-http"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_service_accounts = [google_service_account.eos_sign.email, google_service_account.eos_peer.email, google_service_account.eos_web.email]
  depends_on              = [module.network]
}

# allow tcp port 9876- nodeos runs on port 9876
resource "google_compute_firewall" "allow-tcp-9876" {
  project = var.project_id
  name    = "fw-allow-tcp-9876"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["9876"]
  }
  target_service_accounts = [google_service_account.eos_sign.email, google_service_account.eos_peer.email, google_service_account.eos_web.email]
  depends_on              = [module.network]
}

# allow ssh port 22
resource "google_compute_firewall" "allow-ssh-2" {
  project = var.project_id
  name    = "fw-allow-ssh-22"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_service_accounts = [google_service_account.eos_sign.email, google_service_account.eos_peer.email, google_service_account.eos_web.email]
  depends_on              = [module.network]
}

#allow local communication on 8888 , "35.191.0.0/16","130.211.0.0/22" ip ranges are used by Google cloud for healthcheck

resource "google_compute_firewall" "allow-http-8888" {
  project       = var.project_id
  name          = "internal-only-8888"
  network       = var.network_name
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "${var.subnet_range}"]
  allow {
    protocol = "tcp"
    ports    = ["8888"]
  }
  depends_on = [module.network]
}

module "cloud_nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  project_id    = var.project_id
  region        = var.region
  create_router = true
  router        = "bprouter"
  network       = var.network_name
  depends_on    = [module.network]
}

module "web_instance_template" {
  source               = "terraform-google-modules/vm/google//modules/instance_template"
  version              = "~> 6.6"
  project_id           = var.project_id
  name_prefix          = var.eos_web_prefix
  machine_type         = var.eos_web_machine_type
  source_image_family  = "ubuntu-1804-lts"
  source_image_project = "ubuntu-os-cloud"
  region               = var.region
  startup_script       = data.template_file.web_instance_startup_script.rendered
  disk_size_gb         = var.eos_web_disk_size
  disk_type            = var.eos_web_disk_type
  auto_delete          = "true"
  subnetwork           = var.subnet_name
  subnetwork_project   = var.network_project_id
  service_account = {
    email  = google_service_account.eos_web.email
    scopes = ["cloud-platform"]
  }
  tags       = ["eos-node", "eos-web"]
  depends_on = [module.network]
}


module "web_mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 6.4.0"

  project_id          = var.project_id
  region              = var.region
  target_size         = 2
  hostname            = "web-managed-instance"
  instance_template   = module.web_instance_template.self_link
  health_check        = var.health_check
  max_replicas        = var.web_max_replicas
  min_replicas        = var.web_min_replicas
  cooldown_period     = var.web_cooldown_period
  autoscaling_cpu     = var.web_autoscaling_cpu
  autoscaling_enabled = "true"
  named_ports = [{
    name = "http-web"
    port = 8888
    },
    {
      name = "tcp-web"
      port = 9876
    },
  ]
}

resource "google_compute_backend_service" "web_tcplb_backend" {
  project               = var.project_id
  name                  = "web-tcp-backend"
  protocol              = "TCP"
  port_name             = "tcp-web"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = module.web_mig.instance_group
  }

  health_checks = [google_compute_health_check.web_tcp_health_check.id]
}

resource "google_compute_health_check" "web_tcp_health_check" {
  project             = var.project_id
  name                = "web-tcp-hc"
  description         = "Health check for web nodes via TCP"
  timeout_sec         = 10
  check_interval_sec  = 30
  healthy_threshold   = 1
  unhealthy_threshold = 5

  tcp_health_check {
    port = "9876"
  }
}

resource "google_compute_target_tcp_proxy" "web_tcp_9876" {
  project = var.project_id

  name            = "web-tcp-proxy"
  backend_service = google_compute_backend_service.web_tcplb_backend.id
}

resource "google_compute_global_forwarding_rule" "web_tcp_fr" {
  provider   = google-beta
  project    = var.project_id
  name       = "web-tcp-forwarding-rule"
  port_range = 8099
  target     = google_compute_target_tcp_proxy.web_tcp_9876.id
}


module "web_http_lb" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 4.4"

  project           = var.project_id
  name              = "web-http-lb"
  target_tags       = ["eos-web"]
  firewall_projects = [var.network_project_id]
  firewall_networks = [var.network_name]
  backends = {
    default = {
      description             = null
      protocol                = "HTTP"
      port                    = "80"
      port_name               = "http-web"
      timeout_sec             = 120
      enable_cdn              = false
      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = null

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = 300
        timeout_sec         = 120
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/v1/chain/get_info"
        port                = "8888"
        host                = null
        logging             = null
      }

      log_config = {
        enable      = false
        sample_rate = null
      }

      groups = [
        {
          # Each node pool instance group should be added to the backend.
          group                        = module.web_mig.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
}

# Peer
module "peer_instance_template" {
  source               = "terraform-google-modules/vm/google//modules/instance_template"
  version              = "~> 6.4.0"
  project_id           = var.project_id
  name_prefix          = var.eos_peer_prefix
  machine_type         = var.eos_peer_machine_type
  source_image_family  = "ubuntu-1804-lts"
  source_image_project = "ubuntu-os-cloud"
  region               = var.region
  startup_script       = data.template_file.peer_instance_startup_script.rendered
  disk_size_gb         = var.eos_peer_disk_size
  disk_type            = var.eos_peer_disk_type
  auto_delete          = "true"
  network              = var.network_name
  subnetwork           = var.subnet_name
  subnetwork_project   = var.network_project_id
  service_account = {
    email  = google_service_account.eos_peer.email
    scopes = ["cloud-platform"]
  }
  tags = ["eos-node", "eos-peer"]

  depends_on = [module.network]
}

module "peer_mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 6.4.0"

  project_id          = var.project_id
  region              = var.region
  target_size         = 2
  hostname            = "peer-managed-instance"
  instance_template   = module.peer_instance_template.self_link
  health_check        = var.health_check
  max_replicas        = var.web_max_replicas
  min_replicas        = var.web_min_replicas
  cooldown_period     = var.web_cooldown_period
  autoscaling_cpu     = var.web_autoscaling_cpu
  autoscaling_enabled = "true"
  named_ports = [{
    name = "http-peer"
    port = 8888
    },
    {
      name = "tcp-peer"
      port = 9876
    },
  ]
}

resource "google_compute_backend_service" "peer_tcplb_backend" {
  project               = var.project_id
  name                  = "peer-tcp-backend"
  protocol              = "TCP"
  port_name             = "tcp-peer"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = module.peer_mig.instance_group
  }

  health_checks = [google_compute_health_check.peer_tcp_health_check.id]
}

resource "google_compute_health_check" "peer_tcp_health_check" {
  project             = var.project_id
  name                = "peer-tcp-hc"
  description         = "Health check for peer nodes via TCP"
  timeout_sec         = 10
  check_interval_sec  = 30
  healthy_threshold   = 1
  unhealthy_threshold = 5

  tcp_health_check {
    port = "9876"
  }
}

resource "google_compute_target_tcp_proxy" "peer_tcp_9876" {
  project         = var.project_id
  name            = "peer-tcp-proxy"
  backend_service = google_compute_backend_service.peer_tcplb_backend.id
}

resource "google_compute_global_forwarding_rule" "peer_tcp_fr" {
  provider   = google-beta
  project    = var.project_id
  name       = "peer-tcp-forwarding-rule"
  port_range = 8099
  target     = google_compute_target_tcp_proxy.peer_tcp_9876.id
}

module "peer_http_lb" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 4.4"

  project           = var.project_id
  name              = "peer-http-lb"
  target_tags       = ["eos-peer"]
  firewall_projects = [var.network_project_id]
  firewall_networks = [var.network_name]
  backends = {
    default = {
      description             = null
      protocol                = "HTTP"
      port                    = "80"
      port_name               = "http-peer"
      timeout_sec             = 120
      enable_cdn              = false
      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = null

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = 300
        timeout_sec         = 120
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/v1/chain/get_info"
        port                = "8888"
        host                = null
        logging             = null
      }

      log_config = {
        enable      = false
        sample_rate = null
      }

      groups = [
        {
          # Each node pool instance group should be added to the backend.
          group                        = module.peer_mig.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
  depends_on = [module.network]
}


module "sign_instance_template" {
  source               = "terraform-google-modules/vm/google//modules/instance_template"
  version              = "~> 6.0"
  project_id           = var.project_id
  name_prefix          = var.eos_sign_prefix
  machine_type         = var.eos_sign_machine_type
  region               = var.region
  source_image_family  = "ubuntu-1804-lts"
  source_image_project = "ubuntu-os-cloud"
  startup_script       = data.template_file.sign_instance_startup_script.rendered
  disk_size_gb         = var.eos_sign_disk_size
  disk_type            = var.eos_sign_disk_type
  auto_delete          = "true"
  subnetwork           = var.subnet_name
  subnetwork_project   = var.network_project_id
  service_account = {
    email  = google_service_account.eos_sign.email
    scopes = ["cloud-platform"]
  }
  tags       = ["eos-node", "eos-sign"]
  depends_on = [module.network]
}

module "sign_mig" {
  source              = "terraform-google-modules/vm/google//modules/mig"
  version             = "~> 6.4.0"
  project_id          = var.project_id
  region              = var.region
  target_size         = 2
  hostname            = "sign-managed-instance"
  instance_template   = module.sign_instance_template.self_link
  health_check        = var.health_check
  max_replicas        = var.sign_max_replicas
  min_replicas        = var.sign_min_replicas
  cooldown_period     = var.sign_cooldown_period
  autoscaling_cpu     = var.sign_autoscaling_cpu
  autoscaling_enabled = "true"
}

resource "google_compute_instance" "check" {
  project = var.project_id

  name         = "swap"
  machine_type = "e2-highmem-4"
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-bionic-v20210514"
      size  = "500"
    }
  }
  allow_stopping_for_update = true

  network_interface {
    subnetwork         = var.subnet_name
    subnetwork_project = var.network_project_id
  }
  metadata_startup_script = data.template_file.swap_instance_startup_script.rendered
  service_account {
    email  = google_service_account.eos_sign.email
    scopes = ["cloud-platform"]
  }
  tags       = ["eos-node"]
  depends_on = [module.network]
}
