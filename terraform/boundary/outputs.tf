output "azuread_auth_method_id" {
  value       = boundary_auth_method_oidc.azuread.id
  description = "Azure AD auth method ID"
}

output "database_admin_target_id" {
  value       = boundary_target.db_admin.id
  description = "Target ID for static MSSQL endpoint for database admins"
}

output "developer_scope_id" {
  value       = boundary_scope.application.id
  description = "Scope ID for developers accessing applications"
}

output "developer_database_host_set_id" {
  value       = boundary_host_set_static.db_app.id
  description = "Host set ID for developers accessing database"
}