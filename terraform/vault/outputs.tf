# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "developer_target_id" {
  value       = boundary_target.db_app.id
  description = "Target ID for static MSSQL endpoint for developers"
}