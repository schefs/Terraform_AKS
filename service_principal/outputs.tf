output "aks_role_name" {
  value = try(azurerm_role_definition.aks_sp_role_rg[0].name,"")
}

output "aks_role_id" {
  value = try(azurerm_role_definition.aks_sp_role_rg[0].id,"")
}

output "aks_role_definition_id" {
  value = try(azurerm_role_definition.aks_sp_role_rg[0].role_definition_id,"")
}

output "aks_role_permissions" {
  value = try(azurerm_role_definition.aks_sp_role_rg[0].permissions,"")
}

output "sp_id" {
  value = azuread_service_principal.aks_sp.id
}

output "sp_display_name" {
  value = azuread_service_principal.aks_sp.display_name
}

output "sp_client_id" {
  value = azuread_service_principal.aks_sp.application_id
}

output "sp_client_secret" {
  sensitive = true
  value     = random_string.aks_sp_password.result
}