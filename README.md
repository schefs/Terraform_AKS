# Terraform_AKS
TF AKS module for total private AKS cluster AAD Enabled including SP creation with optional regular/spot node pools

tested on TF 0.12+ versions inclding 0.12 syntax

# Usage example

    # Set to true to assign custom role definition for sp to use
    variable "set_sp_least_privilidge_role" {
      default     = true
      description = "This feature creates a limited role for use by the K8s Service principal which limits access to only those resources needed for k8s operation"
    }

    module "service_principal" {
      source = "./service_principal"
      # Variables
      subscription                 = data.azurerm_subscription.current.id
      set_sp_least_privilidge_role = var.set_sp_least_privilidge_role
      sp_name                      = "${local.env_prefix}_sp_name"
    }

    module "aks" {
      source = "./aks"
      # Variables
      cluster_name                    = "${local.env_prefix}-aks"
      k8s_version                     = local.k8s_version[terraform.workspace]
      default_agent_pool_profile      = local.default_agent_pool_profile
      additional_agent_pool_profile   = local.additional_agent_pool_profile
      aks_resource_group              = local.resource_group
      api_server_authorized_ip_ranges = null
      private_cluster_enabled         = local.k8s_private_cluster_enabled[terraform.workspace]
      cluster_sp_client_id            = module.service_principal.sp_client_id
      cluster_sp_client_secret        = module.service_principal.sp_client_secret
      LB_outbound_type                = local.k8s_LB_outbound_type[terraform.workspace]
      azure_active_directory          = local.k8s_azure_active_directory_block[terraform.workspace]
      node_resource_group_name        = local.aks_node_resource_group_name
      tags = merge(local.GLOBAL_TAGS, {
        aks = "true"
      })
      linux_admin_username      = var.linux_vm_admin_username
      linux_admin_ssh_publickey = file(var.aks_node_public_ssh_key_path)
    }

# Variables used


    variable aks_node_public_ssh_key_path {
      default = "~/.ssh/project/id_rsa.pub"
    }

    variable "linux_vm_admin_username" {
      default = "admin_project"
    }


    locals {
      aks_node_resource_group_name = "${module.infra.resource_group.name}_aks_data"
      k8s_azure_active_directory_block = {
        dev = {
          managed = true
          admin_group_object_ids = local.k8s_admin_group_object_ids[terraform.workspace]
        }
        prod = {
          managed = true
          admin_group_object_ids = local.k8s_admin_group_object_ids[terraform.workspace]

        }
      }
      k8s_admin_group_object_ids = {
        dev = ["*************************************"] // AD group object id
        prod = ["*************************************"] // AD group object id
      }
      k8s_version = {
        dev  = "1.18.6"
        prod = "1.18.6"
      }

     k8s_private_cluster_enabled = {
        dev  = true
        prod = true
      }

      k8s_LB_outbound_type = {
        dev = "userDefinedRouting"
        prod = "userDefinedRouting"
      }

     env_to_default_agent_pool_profile = {
        dev = {
          name = "deva"
          node_count = 1
          vm_size = "Standard_B2s"
          os_disk_size_gb = 250
          vnet_subnet_id = module.infra.subnet.id
          type = "VirtualMachineScaleSets"
          node_taints = []
          //["DefaultNodePool=true:NoSchedule"]
          enable_auto_scaling = false
          min_count = null
          max_count = null
          max_pods = 30
          availability_zones = []
          node_labels = merge(local.GLOBAL_TAGS,{aks_node = true})
          tags = merge(local.GLOBAL_TAGS,{aks_node_pool = true})
        },
        prod = {
          name = "proda"
          node_count = 1
          vm_size = "Standard_B2s"
          os_disk_size_gb = 250
          vnet_subnet_id = module.infra.subnet.id
          type = "VirtualMachineScaleSets"
          node_taints = []
          //["DefaultNodePool=true:NoSchedule"]
          enable_auto_scaling = false
          min_count = null
          max_count = null
          max_pods = 30
          availability_zones = []
          node_labels = merge(local.GLOBAL_TAGS,{aks_node = true})
          tags = merge(local.GLOBAL_TAGS,{aks_node_pool = true})
        }
      }

      env_to_additional_agent_pool_profile = {
        dev = {
          pool1 = {
            name = "devb"
            //node_count      = 5
            vm_size = "Standard_D4s_v3"
            os_type = "Linux"
            os_disk_size_gb = 250
            vnet_subnet_id = module.infra.subnet.id
            max_pods = 100
            enable_auto_scaling = true
            min_count = 10
            max_count = 20
            availability_zones = []
            priority = "Spot"
            eviction_policy = "Delete"
            spot_max_price = -1
            enable_node_public_ip = false
            node_taints = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
            node_labels = merge(local.GLOBAL_TAGS,{"aks_node" = "true", "kubernetes.azure.com/scalesetpriority" = "spot"})
            tags = merge(local.GLOBAL_TAGS,{aks_node_pool = true})
          }
        }
        prod = {
          pool1 = {
            name = "prodb"
            //node_count          = 20
            vm_size = "Standard_F8s_v2"
            os_type = "Linux"
            os_disk_size_gb = 250
            vnet_subnet_id = module.infra.subnet.id
            enable_auto_scaling = true
            min_count = 6
            max_count = 100
            max_pods = 30
            availability_zones = [
              "1",
              "2",
              "3"]
            priority = "Regular"
            eviction_policy = null
            spot_max_price = -1
            enable_node_public_ip = false
            node_taints = []
            tags = merge(local.GLOBAL_TAGS,{aks_node = true})
            node_labels = merge(local.GLOBAL_TAGS,{aks_node = true})
          }
        }


      default_agent_pool_profile = local.env_to_default_agent_pool_profile[terraform.workspace]
      additional_agent_pool_profile = local.env_to_additional_agent_pool_profile[terraform.workspace]

      GLOBAL_TAGS_BY_ENV = {
        dev = {
          "owner" = "me"
          "project" = "test"
          "environment" = "Dev"
          "terraform" = "true"
        }
        prod = {
          "owner" = "me"
          "project" = "test"
          "environment" = "Prod"
          "terraform" = "true"
        }
      }
      GLOBAL_TAGS = local.GLOBAL_TAGS_BY_ENV[terraform.workspace]
    }


















