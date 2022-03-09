# Securing Access to Azure SQL Database with HashiCorp Boundary

This directory contains an example deployment of Boundary
using Terraform Cloud. The lab environment is
meant to accompany the Hashicorp Learn Boundary tutorial for
securing access to Azure SQL Database.

In this example, Boundary, Vault, Azure Active Directory users, and
Azure SQL Database are deployed using Terraform Cloud.

> __NOTE__: This demo will create 100+ resources and incur a cost on Azure. It will take more than 30 minutes to create resources.

## Prerequisites

- A [Boundary binary](https://www.boundaryproject.io/downloads) greater than
  0.7.1 in your `PATH`

- A [Terraform binary](/tutorials/terraform/install-cli) greater than 1.0.0 in
  your `PATH`.

- A [Vault binary](/tutorials/vault/getting-started/install) greater than 1.9.3
  in your `PATH`.

- A [Terraform Cloud](tutorials/terraform/cloud-sign-up#create-an-account) test
  account. **This tutorial requires the creation of new cloud resources that
  will take over 30 minutes. Use Terraform Cloud to deploy resources and avoid
  errors.**

- A [Microsoft Azure](https://portal.azure.com/) test account. **This tutorial
  requires the creation of new cloud resources and will incur costs associated
  with the deployment and management of these resources.**

- Install the [Azure
  CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli). The
  executable must be available within your `PATH`.

- A [`sqlcmd`
  utility](https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility) in your
  `PATH`.

- A [`jq` binary](https://stedolan.github.io/jq/download/) greater than 1.6 in
  your `PATH`.

## Getting Started

There is a helper script called `run` in this directory. You can use this script to deploy, login, and cleanup.

### Configure Credentials

1. [Install](https://learn.hashicorp.com/tutorials/terraform/install-cli) Terraform v1.0+.

1. Set up a [Terraform Cloud account](https://learn.hashicorp.com/tutorials/terraform/cloud-sign-up#create-an-account).

1. In your terminal, generate a [Terraform Cloud API token](https://www.terraform.io/cli/commands/login).
   ```shell
   terraform login
   ```

1. Set the Azure subscription ID as an environment variable.
   ```shell
   export AZURERM_SUBSCRIPTION_ID=<your Azure subscription ID>
   ```

1. Configure an
  [Azure service principal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#creating-a-service-principal)
  with `Owner` role for a subscription. Terraform uses this service principal to create resources.
   ```shell
   az ad sp create-for-rbac --role="Owner" \
      --scopes="/subscriptions/${AZURERM_SUBSCRIPTION_ID}" \
      --name "Terraform Cloud (learn-boundary-azure-sql-database)" > azure.json
   ```

1. Save the application (client) ID, client secret (password), tenant ID, and subscription ID.

1. You will need to add additional access for Terraform to create Azure AD users and groups.

   - Set the client ID to the `AZURERM_CLIENT_ID` environment variable.
     ```shell
     export AZURERM_CLIENT_ID=<application ID>
     ```

   - Add API permissions to Microsoft Graph API and Azure Key Vault and grant admin consent.
     ```shell
     bash bootstrap/tf-ad.sh
     ```

### Deploy Example Infrastructure

This demo will create 100+ resources and incur a cost on Azure.
It will take more than 30 minutes to create resources. Terraform Cloud
helps run Terraform if your local machine cannot keep a session open.
You will need a Terraform Cloud organization and three workspaces.

> __NOTE:__ The deployment may error out. If it does, force cancel the run in Terraform Cloud and re-apply the deployment.

1. Add your Azure credentials, email for Terraform Cloud, Azure AD domain for usernames
   to `secrets.tfvars`.
   ```hcl
   azure_credentials = {
      arm_client_id       = "${CLIENT_ID}"
      arm_client_secret   = "${CLIENT_SECRET}"
      arm_subscription_id = "${SUBSCRIPTION_ID}"
      arm_tenant_id       = "${APPLICATION_ID}"
   }

   email = "${TFC_EMAIL}"

   azure_ad_domain = "${AZURE_AD_DOMAIN_NAME}"
   ```

1. Create the Terraform workspace and infrastructure.
   Terraform will load all of the secrets you
   defined into the appropriate workspace.
   ```shell
   ./run all
   ```

## Connect to Azure SQL Database

Once the deployment is live, you can connect to the database as one of two personas.
The database administrator can load data into a table and select rows. The developer
can only select rows.

### Database Administrator

To log in as a database administrator, you must authenticate to Boundary.

1. Copy the Azure AD username for the database administrator.
   ```shell
   export SQLCMDUSER=$(cd terraform/infrastructure && terraform output -raw azuread_user_database_username)
   ```

1. Copy the Azure AD username for the database administrator.
   ```shell
   export SQLCMDPASSWORD=$(cd terraform/infrastructure && terraform output -raw azuread_user_database_admin_password)
   ```

1. Log into Boundary. This will delegate authentication to Azure AD.
   Use the values in the `SQLCMDUSER` and `SQLCMDPASSWORD` environment variables
   to log into Azure AD.
   ```shell
   ./run login
   ```

1. Start the Boundary proxy on port 1433.
   ```shell
   ./run admin_proxy
   ```

1. As a database administrator, you can load data into the database.
   Start a new terminal and import the data to the `DemoExpenses` database.
   ```shell
   ./run data
   ```

### Developer

To log in as a developer, you must authenticate to Boundary.

1. Copy the Azure AD username for the developer.
   ```shell
   export DEVELOPER_USERNAME=$(cd terraform/infrastructure && terraform output -raw azuread_user_developer_username)
   ```

1. Copy the Azure AD username for the developer.
   ```shell
   export DEVELOPER_PASSWORD=$(cd terraform/infrastructure && terraform output -raw azuread_user_developer_password)
   ```

1. Log into Boundary. This will delegate authentication to Azure AD.
   Use the values in the `DEVELOPER_USERNAME` and `DEVELOPER_PASSWORD` environment variables
   to log into Azure AD.
   ```shell
   ./run login
   ```

1. Start the Boundary proxy on port 1433. This will output a temporary username and password generated
   by HashiCorp Vault.
   ```shell
   $ ./run dev_proxy

   Proxy listening information:
     Address:             127.0.0.1
     Connection Limit:    1
     Expiration:          Fri, 11 Mar 2022 21:24:07 EST
     Port:                1433
     Protocol:            tcp
     Session ID:          s_OtL5JmMYau
     Credentials:
       Credential Source Description: Vault credential library for developer database access
       Credential Source ID:          clvlt_c8iS6OuQt1
       Credential Source Name:        database
       Credential Store ID:           csvlt_uHXjLPoEqa
       Credential Store Type:         vault
       Secret:
           {
                 "password": "REDACTED",
                 "username": "v-token-token-app-i8LoUpOvwWQXno6MUuwJ-1647023047"
           }
   ```

1. Open a new terminal. Copy the database username and set it to the `SQLCMDUSER` environment variable.
   ```shell
   export SQLCMDUSER=<username from secret output>
   ```

1. Copy the database password and set it to the `SQLCMDPASSWORD` environment variable.
   ```shell
   export SQLCMDPASSWORD=<password from secret output>
   ```

1. As a developer, you can only read data from the database using the credentials.
   Log into the `DemoExpenses` database.
   ```shell
   ./run dev
   ```

1. You can select items from the database.
   ```shell
   1> select * from expenseitems;
   2> go

   (0 rows affected)
   ```

1. However, you cannot change items in the database.
   ```shell
   1> insert into expenseitems (Id,Name) values (0,'test')
   2> go

   Msg 229, Level 14, State 5, Server caribou-learn-database, Line 1
   The INSERT permission was denied on the object 'ExpenseItems', database 'DemoExpenses', schema 'dbo'.
   ```

## Cleanup

You can delete all secrets, resources, and configurations with the helper script.

```shell
./run cleanup
```