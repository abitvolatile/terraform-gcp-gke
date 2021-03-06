### Terraform Resources


# Setting local variables for the sake of reusability of resouces described below
locals {
  kube_cluster_name = "${var.kube_cluster_prefix}"
}



# Enabled Google APIs
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container" {
  depends_on = [
    google_project_service.compute
  ]

  service            = "container.googleapis.com"
  disable_on_destroy = false
}



# Networking Resources
resource "google_compute_subnetwork" "kubernetes" {
  depends_on = [
    google_project_service.compute
  ]

  name                     = "${local.kube_cluster_name}-subnet"
  network                  = var.google_compute_network
  region                   = var.google_region["single"]
  ip_cidr_range            = "10.100.160.0/19"
  private_ip_google_access = true

  secondary_ip_range = [
    {
      range_name    = "kubernetes-pods"
      ip_cidr_range = "10.100.0.0/17"
    },
    {
      range_name    = "kubernetes-services"
      ip_cidr_range = "10.100.192.0/18"
    }
  ]
}


resource "google_compute_firewall" "allow-ssh-kubernetes" {
  name    = "allow-ssh-kubernetes"
  network = var.google_compute_network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.local_public_ip]
  target_tags   = ["kubernetes"]
}



# Service Account + IAM Binding
resource "google_service_account" "kubernetes-service-account" {
  account_id   = "${local.kube_cluster_name}-svc-acct"
  display_name = "Kubernetes ${local.kube_cluster_name} Service Account"
}


resource "google_project_iam_member" "kubernetes-service-account-editor" {
  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.kubernetes-service-account.email}"
}



# Resource Collection

data "google_compute_zones" "available" {
  depends_on = [
    google_project_service.compute
  ]

  provider = google-beta
  region   = var.google_region["single"]
}

data "google_client_openid_userinfo" "provider_identity" {}

data "google_service_account_access_token" "kubernetes_sa" {
  target_service_account = data.google_client_openid_userinfo.provider_identity.email
  scopes                 = ["userinfo-email", "cloud-platform"]
  lifetime               = "3600s"
}



# Kubernetes Cluster

resource "google_container_cluster" "kubernetes-cluster" {
  depends_on = [
    google_project_iam_member.kubernetes-service-account-editor,
    google_project_service.container
  ]
  provider = google-beta

  name     = "${local.kube_cluster_name}-cluster"
  location = var.google_region["single"]
  node_locations = [
    "${data.google_compute_zones.available.names[0]}",
    "${data.google_compute_zones.available.names[1]}",
    "${data.google_compute_zones.available.names[2]}"
  ]

  min_master_version = var.kube_cluster_version
  node_version       = var.kube_cluster_version

  network    = var.google_compute_network
  subnetwork = google_compute_subnetwork.kubernetes.name
  ip_allocation_policy {
    cluster_secondary_range_name  = "kubernetes-pods"
    services_secondary_range_name = "kubernetes-services"
  }

  initial_node_count       = 1
  remove_default_node_pool = true

  node_config {
    tags         = ["kubernetes"]
    preemptible  = true
    machine_type = var.kube_nodepool_instance_type
    disk_size_gb = var.kube_nodepool_disk_size
    oauth_scopes = [
      "cloud-platform"
    ]
    service_account = google_service_account.kubernetes-service-account.email
    labels = {
      "cloud.google.com/gke-preemptible" = "true"
    }
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }

  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      maximum       = 4
    }
    resource_limits {
      resource_type = "memory"
      maximum       = 32
    }
  }

  monitoring_service = "monitoring.googleapis.com/kubernetes"
  logging_service    = "logging.googleapis.com/kubernetes"

  addons_config {
    http_load_balancing {
      disabled = false
    }
    kubernetes_dashboard {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    istio_config {
      disabled = false
      auth     = "AUTH_NONE"
    }
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  lifecycle {
    ignore_changes = [
      node_version,
      node_locations,
      node_pool
    ]
  }
}


# Kubernetes NodePool
resource "google_container_node_pool" "node-pool-a" {
  provider = google-beta

  cluster  = google_container_cluster.kubernetes-cluster.name
  name     = "nodepool-a"
  location = var.google_region["single"]

  version            = var.kube_cluster_version
  initial_node_count = 1

  node_config {
    tags         = ["kubernetes"]
    preemptible  = true
    machine_type = var.kube_nodepool_instance_type
    disk_size_gb = var.kube_nodepool_disk_size
    oauth_scopes = [
      "cloud-platform"
    ]
    service_account = google_service_account.kubernetes-service-account.email
    labels = {
      "cloud.google.com/gke-preemptible" = "true"
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 10
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  lifecycle {
    ignore_changes = [
      version
    ]
  }
}
