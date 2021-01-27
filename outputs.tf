output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "kube_config_admin" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
}

output "cluster_details_client_key" {
  value = "${base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)}"
}

output "cluster_details_ca" {
  value = "${base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)}"
}

output "cluster_FQDN" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}

output "cluster_private_FQDN" {
  value = azurerm_kubernetes_cluster.aks.private_fqdn
}

output "kubernetes_version" {
  value = azurerm_kubernetes_cluster.aks.kubernetes_version
}

output "subnet_id" {
  value = "${azurerm_kubernetes_cluster.aks.default_node_pool.0.vnet_subnet_id}"
}

output "network_plugin" {
  value = "${azurerm_kubernetes_cluster.aks.network_profile.0.network_plugin}"
}

output "service_cidr" {
  value = "${azurerm_kubernetes_cluster.aks.network_profile.0.service_cidr}"
}

output "dns_service_ip" {
  value = "${azurerm_kubernetes_cluster.aks.network_profile.0.dns_service_ip}"
}

output "docker_bridge_cidr" {
  value = "${azurerm_kubernetes_cluster.aks.network_profile.0.docker_bridge_cidr}"
}

output "pod_cidr" {
  value = "${azurerm_kubernetes_cluster.aks.network_profile.0.pod_cidr}"
}

output "api_server_authorized_ip_ranges" {
  value = "${azurerm_kubernetes_cluster.aks.api_server_authorized_ip_ranges}"
}

output "aks_host" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.host}"
}
output "aks_private_fqdn" {
  value = azurerm_kubernetes_cluster.aks.private_fqdn
}
output "private_dns_zone_id" {
  value = data.azurerm_private_dns_zone.private_aks_private_dns_zone.id
}
output "private_dns_zone_name" {
  value = data.azurerm_private_dns_zone.private_aks_private_dns_zone.name
}
output "aks_resource_group" {
  value = azurerm_kubernetes_cluster.aks.resource_group_name
}
output "aks_node_resource_group_name" {
  value = var.node_resource_group_name
}