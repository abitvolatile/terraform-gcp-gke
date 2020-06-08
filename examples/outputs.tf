# Output Variables

output "google_project_name" {
  description = "Google Project Name"
  value       = module.project.google_project_name
}

output "google_project_id" {
  description = "Google Project ID"
  value       = module.project.google_project_id
}

output "google_project_number" {
  description = "Google Project Number"
  value       = module.project.google_project_number
}

output "google_billing_account" {
  description = "Google Billing Account ID"
  value       = module.project.google_billing_account
}

output "google_org_id" {
  description = "Google Organization ID number"
  value       = module.project.google_org_id
}

output "google_compute_network_name" {
  description = "Google VPC Network Name"
  value       = module.vpc-networking.google_compute_network_name
}

output "local_public_ip" {
  description = "Public IP Address"
  value       = module.public_ip.public_ip
}

output "kubernetes_cluster_name" {
  description = "Google Kubernetes Engine Cluster Name"
  value       = module.kubernetes.kubernetes_cluster_name
}

output "kubernetes_nodepool_a_name" {
  description = "Google Kubernetes Engine Node Pool Name"
  value       = module.kubernetes.kubernetes_nodepool_a_name
}

output "kubernetes_cluster_endpoint" {
  description = "Google Kubernetes Engine Cluster Endpoint"
  value       = module.kubernetes.kubernetes_cluster_endpoint
}

output "kubernetes_cluster_client_certificate" {
  description = "Google Kubernetes Engine Client Certificate"
  value       = module.kubernetes.kubernetes_cluster_client_certificate
  sensitive   = true
}

output "kubernetes_cluster_client_key" {
  description = "Google Kubernetes Engine Client Key"
  value       = module.kubernetes.kubernetes_cluster_client_key
  sensitive   = true
}

output "kubernetes_cluster_ca_certificate" {
  description = "Google Kubernetes Engine CA Certificate"
  value       = module.kubernetes.kubernetes_cluster_ca_certificate
  sensitive   = true
}

output "google_client_openid_userinfo_email" {
  description = "Open ID User's Email Address"
  value       = module.kubernetes.google_client_openid_userinfo_email
}

output "google_service_account_access_token" {
  description = "Kubernetes Auth Token for OpenID User"
  value       = module.kubernetes.google_service_account_access_token
  sensitive   = true
}
