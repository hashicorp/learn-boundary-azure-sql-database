resource "tfe_organization" "learn" {
  name  = local.organization
  email = var.email
}

resource "tfe_workspace" "learn" {
  for_each            = local.workspaces
  name                = each.value
  organization        = tfe_organization.learn.name
  global_remote_state = true
  execution_mode      = "remote"
}

## Add Azure credentials to specific workspaces
resource "tfe_variable" "azure_arm_subscription_id" {
  for_each     = local.azure_credentials_workspaces
  key          = "ARM_SUBSCRIPTION_ID"
  value        = var.azure_credentials.arm_subscription_id
  category     = "env"
  workspace_id = tfe_workspace.learn[each.value].id
  description  = "Azure Subscription ID"
}

resource "tfe_variable" "azure_arm_tenant_id" {
  for_each     = local.azure_credentials_workspaces
  key          = "ARM_TENANT_ID"
  value        = var.azure_credentials.arm_tenant_id
  category     = "env"
  workspace_id = tfe_workspace.learn[each.value].id
  description  = "Azure Tenant ID"
}

resource "tfe_variable" "azure_arm_client_id" {
  for_each     = local.azure_credentials_workspaces
  key          = "ARM_CLIENT_ID"
  value        = var.azure_credentials.arm_client_id
  category     = "env"
  workspace_id = tfe_workspace.learn[each.value].id
  description  = "Azure Client ID"
}

resource "tfe_variable" "azure_arm_client_secret" {
  for_each     = local.azure_credentials_workspaces
  key          = "ARM_CLIENT_SECRET"
  value        = var.azure_credentials.arm_client_secret
  category     = "env"
  workspace_id = tfe_workspace.learn[each.value].id
  sensitive    = true
  description  = "Azure Client Secret"
}

## Terraform variables for infrastructure workspace
resource "tfe_variable" "azure_ad_domain" {
  key          = "azure_ad_domain"
  value        = var.azure_ad_domain
  category     = "terraform"
  workspace_id = tfe_workspace.learn["infrastructure"].id
  sensitive    = true
  description  = "Azure AD domain for usernames"
}

## Terraform variables for vault workspace
resource "tfe_variable" "vault" {
  key          = "VAULT_TOKEN"
  value        = var.vault_token
  category     = "env"
  workspace_id = tfe_workspace.learn["vault"].id
  sensitive    = true
  description  = "Variable for Vault root token"
}