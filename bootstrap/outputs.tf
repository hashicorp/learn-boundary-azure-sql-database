resource "local_file" "globals" {
  for_each = local.workspaces
  content  = <<EOT
prefix = "${random_pet.org.id}"
tags = {
  purpose = "${local.organization}"
  source  = "hashicorp-learn"
}
EOT
  filename = "../terraform/${each.value}/globals.auto.tfvars"
}

resource "local_file" "backends" {
  for_each = local.workspaces
  content  = <<EOT
terraform {
  backend "remote" {
    organization = "${local.organization}"

    workspaces {
      name = "${each.value}"
    }
  }
}
EOT
  filename = "../terraform/${each.value}/backend.tf"
}

resource "local_file" "boundary" {
  content  = <<EOT
data "terraform_remote_state" "infrastructure" {
  backend = "remote"

  config = {
    organization = "${local.organization}"
    workspaces = {
      name = "infrastructure"
    }
  }
}
EOT
  filename = "../terraform/boundary/dependencies.tf"
}

resource "local_file" "vault" {
  content  = <<EOT
data "terraform_remote_state" "infrastructure" {
  backend = "remote"

  config = {
    organization = "${local.organization}"
    workspaces = {
      name = "infrastructure"
    }
  }
}

data "terraform_remote_state" "boundary" {
  backend = "remote"

  config = {
    organization = "${local.organization}"
    workspaces = {
      name = "boundary"
    }
  }
}
EOT
  filename = "../terraform/vault/dependencies.tf"
}