# Output Variables

output "kubernetes_cluster_name" {
  description = "Google Kubernetes Engine Cluster Name"
  value       = "${google_container_cluster.kubernetes-cluster.name}"
}

output "kubernetes_nodepool_a_name" {
  description = "Google Kubernetes Engine Node Pool Name"
  value       = "${google_container_node_pool.node-pool-a.name}"
}

output "kubernetes_cluster_endpoint" {
  description = "Google Kubernetes Engine Cluster Endpoint"
  value       = "${google_container_cluster.kubernetes-cluster.endpoint}"
}

output "kubernetes_cluster_client_certificate" {
  description = "Google Kubernetes Engine Client Certificate"
  value       = "${base64decode(google_container_cluster.kubernetes-cluster.master_auth.0.client_certificate)}"
}

output "kubernetes_cluster_client_key" {
  description = "Google Kubernetes Engine Client Key"
  value       = "${base64decode(google_container_cluster.kubernetes-cluster.master_auth.0.client_key)}"
}

output "kubernetes_cluster_ca_certificate" {
  description = "Google Kubernetes Engine CA Certificate"
  value       = "${base64decode(google_container_cluster.kubernetes-cluster.master_auth.0.cluster_ca_certificate)}"
}

output "google_client_openid_userinfo_email" {
  description = "Open ID User's Email Address"
  value       = "${data.google_client_openid_userinfo.provider_identity.email}"
}

output "google_service_account_access_token" {
  description = "Kubernetes Auth Token for OpenID User"
  value       = "${data.google_service_account_access_token.kubernetes_sa.access_token}"
  sensitive   = true
}
