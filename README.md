# Terraform_AKS
TF AKS module for private AKS cluster AAD Enabled
# Usage example
    module "aks" {
      source = "./aks"
      # Variables
      cluster_name                    = "${local.env_prefix}-aks"
      k8s_version                     = local.k8s_version[terraform.workspace]
      default_agent_pool_profile      = local.internal_default_agent_pool_profile
      additional_agent_pool_profile   = local.internal_additional_agent_pool_profile
      aks_resource_group              = local.internal_resource_group
      api_server_authorized_ip_ranges = null
      private_cluster_enabled         = local.k8s_private_cluster_enabled[terraform.workspace]
      cluster_sp_client_id            = module.internal_service_principal.sp_client_id
      cluster_sp_client_secret        = module.internal_service_principal.sp_client_secret
      LB_outbound_type                = local.k8s_LB_outbound_type[terraform.workspace]
      azure_active_directory          = local.k8s_azure_active_directory_block[terraform.workspace]
      node_resource_group_name        = local.aks_node_resource_group_name
      tags = merge(local.GLOBAL_TAGS, {
        aks = "true"
      })
      linux_admin_username      = var.linux_vm_admin_username
      linux_admin_ssh_publickey = file(var.aks_node_public_ssh_key_path)
    }
