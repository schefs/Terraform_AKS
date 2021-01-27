variable "cluster_name" {}
variable "api_server_authorized_ip_ranges" {
  type = list(string)
}
variable "aks_resource_group" {}
variable "cluster_sp_client_id" {}
variable "cluster_sp_client_secret" {}
variable "LB_outbound_type" {}
variable "node_resource_group_name" {}
variable "azure_active_directory" {
  type = object({
    managed = bool
    admin_group_object_ids = list(string)
  })
  }

variable "default_agent_pool_profile" {
  type = object({
    name                = string
    node_count          = number
    vm_size             = string
    os_disk_size_gb     = number
    vnet_subnet_id      = string
    type                = string
    enable_auto_scaling = string
    min_count           = number
    max_count           = number
    max_pods            = number
    availability_zones  = list(string)
    node_taints         = list(string)
    node_labels         = map(string)
    tags                = map(string)
  })
}
variable "additional_agent_pool_profile" {
  type = map((object({
    name                = string
//    node_count          = number
    vm_size             = string
    os_type             = string
    os_disk_size_gb     = number
    vnet_subnet_id      = string
    enable_auto_scaling = string
    min_count           = number
    max_count           = number
    max_pods            = number
    availability_zones  = list(string)
    node_taints         = list(string)
    tags                = map(string)
    node_labels         = map(string)
    priority            = string
    eviction_policy     = string
    spot_max_price      = number
  })))
}
variable "private_cluster_enabled" {
  default = false
}
variable "tags" {
  type = map(string)
}
variable "k8s_version" {}
variable "linux_admin_username" {}
variable "linux_admin_ssh_publickey" {}