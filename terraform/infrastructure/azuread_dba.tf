locals {
  database_group = "${azurerm_resource_group.resources.name}-database"
}

resource "random_password" "database_admin" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azuread_user" "database" {
  user_principal_name = local.database_username.user_principal_name
  display_name        = local.database_username.display_name
  mail_nickname       = local.database_username.mail_nickname
  password            = random_password.database_admin.result
}

resource "azuread_group" "database" {
  display_name     = local.database_group
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  members          = [azuread_user.database.object_id]
}