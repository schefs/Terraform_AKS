
resource "azurerm_kubernetes_cluster" "aks" {

  name                    = var.cluster_name
  location                = var.aks_resource_group.location
  resource_group_name     = var.aks_resource_group.name
  dns_prefix              = var.cluster_name
  kubernetes_version      = var.k8s_version
  private_cluster_enabled = var.private_cluster_enabled
  node_resource_group     = var.node_resource_group_name
  #api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = var.azure_active_directory["managed"]
      admin_group_object_ids = var.azure_active_directory["admin_group_object_ids"]
    }
  }
  addon_profile {
    kube_dashboard {
      enabled = true
    }

  }


  default_node_pool {
    name                = var.default_agent_pool_profile["name"]
    node_count          = var.default_agent_pool_profile["node_count"]
    vm_size             = var.default_agent_pool_profile["vm_size"]
    os_disk_size_gb     = var.default_agent_pool_profile["os_disk_size_gb"]
    vnet_subnet_id      = var.default_agent_pool_profile["vnet_subnet_id"]
    type                = var.default_agent_pool_profile["type"]
    enable_auto_scaling = var.default_agent_pool_profile["enable_auto_scaling"]
    min_count           = var.default_agent_pool_profile["min_count"]
    max_count           = var.default_agent_pool_profile["max_count"]
    availability_zones  = var.default_agent_pool_profile["availability_zones"]
    node_taints         = var.default_agent_pool_profile["node_taints"]
    tags                = var.default_agent_pool_profile["tags"]
    // Changing Node_labels will recreate the AKS cluster !!!!!
    // Do not apply default node pool node tags unless you are stupid and want to recreate everythig !
    //    node_labels         = var.default_agent_pool_profile["node_labels"]
  }


  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type = var.LB_outbound_type
  }

  linux_profile {

    admin_username = var.linux_admin_username

    ssh_key {
      // If the user hasn't set a key the default will be "user_users_ssh_key", here we check for that and
      // load the ssh from file if this is the case.
      key_data = var.linux_admin_ssh_publickey
    }
  }

  service_principal {
    client_id     = var.cluster_sp_client_id
    client_secret = var.cluster_sp_client_secret
  }


  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }

  # So terraform will not do funky stuff when auto scaller changes node count
//  lifecycle {
//    ignore_changes = [
//      agent_pool_profile.0.count
//    ]
//  }


}

resource "azurerm_kubernetes_cluster_node_pool" "aks_node_pool" {
  for_each              = var.additional_agent_pool_profile
  name                  = each.value.name
  //node_count            = each.value.node_count
  vm_size               = each.value.vm_size
  os_type               = each.value.os_type
  os_disk_size_gb       = each.value.os_disk_size_gb
  vnet_subnet_id        = each.value.vnet_subnet_id
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  max_pods              = each.value.max_pods
  availability_zones    = each.value.availability_zones
  priority              = each.value.priority
  spot_max_price        = each.value.spot_max_price
  eviction_policy       = each.value.eviction_policy
  node_taints           = each.value.node_taints
  node_labels           = each.value.node_labels
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  tags                  = each.value.tags
  // Changing node_labels will recreate the NODE POOL !!!!!
  //node_labels           = each.value.node_labels

}
locals {
  private_aks_fqdn = azurerm_kubernetes_cluster.aks.private_fqdn
  private_aks_private_dns_zone = regex("[-0-9A-Za-z_]*\\.privatelink\\.westeurope\\.azmk8s\\.io",local.private_aks_fqdn )
}

data "azurerm_private_dns_zone" "private_aks_private_dns_zone" {
  name                = local.private_aks_private_dns_zone
  resource_group_name = var.node_resource_group_name
}
