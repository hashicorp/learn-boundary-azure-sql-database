# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "organization" {
  type        = string
  description = "Name of Terraform Cloud organization"
  default     = "learn-boundary-azure-sql"
}

variable "email" {
  type        = string
  description = "Email to use for Terraform Cloud organization"
}

variable "azure_ad_domain" {
  type        = string
  description = "Azure Active Directory domain name to create users"
}

variable "azure_credentials" {
  type = object({
    arm_subscription_id = string
    arm_tenant_id       = string
    arm_client_id       = string
    arm_client_secret   = string
  })
  description = "Azure credentials for Terraform Cloud to use"
  sensitive   = true
}

variable "vault_token" {
  type        = string
  description = "Root token for Vault. Update variable after you create the Vault instance."
  sensitive   = true
  default     = ""
}

resource "random_pet" "org" {
  length = 1
}

locals {
  organization                 = "${random_pet.org.id}-${var.organization}"
  workspaces                   = toset(["infrastructure", "boundary", "vault"])
  azure_credentials_workspaces = toset(["boundary", "infrastructure"])
}