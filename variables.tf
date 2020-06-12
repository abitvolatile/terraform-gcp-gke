# Input Variables

variable "google_project_name" {
  description = "Google Project Name. Must be less than 30 alpha-numberic characters. (Example: tf-gcp-test-project)"
}

variable "google_region" {
  description = "Google Cloud Region"
  type        = map
}

variable "google_compute_network" {
  description = "Google Compute VPC Network Name"
}

variable "local_public_ip" {
  description = "Public IP Address"
}

variable "kube_cluster_prefix" {
  description = "Cluster Prefix Name"
}

variable "kube_cluster_version" {
  description = "GKE Cluster Kubernetes Version"
}

variable "kube_nodepool_disk_size" {
  description = "GKE NodePool Disk Size"
}

variable "kube_nodepool_instance_type" {
  description = "GKE NodePool Instance Type"
}
