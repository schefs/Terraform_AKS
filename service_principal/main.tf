
resource "azuread_application" "aks_app" {
  name = var.sp_name
}

resource "azuread_service_principal" "aks_sp" {
  application_id = azuread_application.aks_app.application_id
}

resource "random_string" "aks_sp_password" {
  length  = 16
  special = true

  keepers = {
    service_principal = azuread_service_principal.aks_sp.id
  }
}

resource "azuread_service_principal_password" "aks_sp_password" {
  service_principal_id = azuread_service_principal.aks_sp.id
  value                = random_string.aks_sp_password.result
  end_date             = "2299-01-01T01:02:03Z"

  # This stops be 'end_date' changing on each run and causing a new password to be set
  # to get the date to change here you would have to manually taint this resource...
  lifecycle {
    ignore_changes = [
    end_date]
  }
}


// Attempt to create a 'least privilidge' role for SP used by AKS
resource "azurerm_role_definition" "aks_sp_role_rg" {
  count       = var.set_sp_least_privilidge_role == true ? 1 : 0
  name        = "${var.sp_name}_role"
  scope       = var.subscription
  description = "This role provides the required permissions needed by Kubernetes to: Manager VMs, Routing rules, Mount azure files and Read container repositories"

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/write",
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/read",
      "Microsoft.Network/loadBalancers/write",
      "Microsoft.Network/loadBalancers/read",
      "Microsoft.Network/routeTables/read",
      "Microsoft.Network/routeTables/routes/read",
      "Microsoft.Network/routeTables/routes/write",
      "Microsoft.Network/routeTables/routes/delete",
      "Microsoft.ContainerRegistry/registries/read",
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Network/publicIPAddresses/write",
      # Network Contributer built-in role:
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/read",
      "Microsoft.Network/virtualNetworks/subnets/write",
      "Microsoft.Network/publicIPAddresses/join/action",
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Network/publicIPAddresses/write",
      # Pull from ACR
      "Microsoft.ContainerRegistry/registries/pull/read",
      # deploy full network contributer built-in role
      "Microsoft.Authorization/*/read",
      "Microsoft.Insights/alertRules/*",
      "Microsoft.Network/*",
      "Microsoft.ResourceHealth/availabilityStatuses/read",
      "Microsoft.Resources/deployments/*",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Support/*"

    ]

    not_actions = [
      // Deny access to all VM actions, this includes Start, Stop, Restart, Delete, Redeploy, Login, Extensions etc
      "Microsoft.Compute/virtualMachines/*/action",

      "Microsoft.Compute/virtualMachines/extensions/*",
    ]
  }

  assignable_scopes = [
    var.subscription,
  ]
}

resource "azurerm_role_assignment" "aks_service_principal_role" {
  count              = var.set_sp_least_privilidge_role == true ? 1 : 0
  scope              = var.subscription
  role_definition_id = azurerm_role_definition.aks_sp_role_rg[0].id
  principal_id       = azuread_service_principal.aks_sp.id

  depends_on = [
    azurerm_role_definition.aks_sp_role_rg,
  ]
}

# Assign AcrPull role to service principal
resource "azurerm_role_assignment" "acrpull_role" {
  scope                            = var.subscription
  role_definition_name             = "AcrPull"
  principal_id                     = azuread_service_principal.aks_sp.id
  skip_service_principal_aad_check = true
}

