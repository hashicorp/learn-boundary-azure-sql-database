# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  developer_group = "${azurerm_resource_group.resources.name}-development"
}

resource "random_password" "developer" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azuread_user" "developer" {
  user_principal_name = local.developer_username.user_principal_name
  display_name        = local.developer_username.display_name
  mail_nickname       = local.developer_username.mail_nickname
  password            = random_password.developer.result
}

resource "azuread_group" "developer" {
  display_name     = local.developer_group
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  members          = [azuread_user.developer.object_id]
}