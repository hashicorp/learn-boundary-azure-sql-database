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

variable "application" {
  type        = string
  description = "application prefix for secrets"
  default     = "expense"
}

variable "mssql_username" {
  type        = string
  description = "Username for SQL server"
  default     = "boundary"
}

variable "mssql_port" {
  type        = string
  description = "port for mysql database"
  default     = "1433"
}

locals {
  # Boundary information
  boundary_url                             = data.terraform_remote_state.infrastructure.outputs.boundary_url
  vault_name                               = data.terraform_remote_state.infrastructure.outputs.key_vault_name
  recovery_service_principal_tenant_id     = data.terraform_remote_state.infrastructure.outputs.boundary_recovery_service_principal_tenant_id
  recovery_service_principal_client_id     = data.terraform_remote_state.infrastructure.outputs.boundary_recovery_service_principal_client_id
  recovery_service_principal_client_secret = data.terraform_remote_state.infrastructure.outputs.boundary_recovery_service_principal_client_secret

  vault_url                  = data.terraform_remote_state.infrastructure.outputs.vault_url
  mssql_password             = data.terraform_remote_state.infrastructure.outputs.mssql_password
  mssql_url                  = data.terraform_remote_state.infrastructure.outputs.mssql_url
  mssql_ip_address           = data.terraform_remote_state.infrastructure.outputs.vault_mssql_ip_address
  mssql_database_name        = data.terraform_remote_state.infrastructure.outputs.mssql_database_name
  boundary_developer_scope   = data.terraform_remote_state.boundary.outputs.developer_scope_id
  boundary_database_host_set = data.terraform_remote_state.boundary.outputs.developer_database_host_set_id
}