# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  type        = string
  description = "Prefix to use for resources"
}

variable "tags" {
  type        = map(string)
  description = "Tags to attach to infrastructure resources"
  default = {
    source = "hashicorp-learn"
  }
}

locals {
  boundary_organization = "${var.prefix}-learn"

  vault_name      = data.terraform_remote_state.infrastructure.outputs.key_vault_name
  subscription_id = data.terraform_remote_state.infrastructure.outputs.subscription_id

  recovery_service_principal_tenant_id     = data.terraform_remote_state.infrastructure.outputs.boundary_recovery_service_principal_tenant_id
  recovery_service_principal_client_id     = data.terraform_remote_state.infrastructure.outputs.boundary_recovery_service_principal_client_id
  recovery_service_principal_client_secret = data.terraform_remote_state.infrastructure.outputs.boundary_recovery_service_principal_client_secret

  azuread_group_dev      = data.terraform_remote_state.infrastructure.outputs.azuread_group_developer
  azuread_group_db       = data.terraform_remote_state.infrastructure.outputs.azuread_group_database
  database_url           = data.terraform_remote_state.infrastructure.outputs.mssql_ip_address
}
