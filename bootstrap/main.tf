# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_version = ">=1.0"
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.28.1"
    }
  }
}

provider "tfe" {}