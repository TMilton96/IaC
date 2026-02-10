# Terraform Azure DevOps Pipeline

This repository contains a production-ready Azure DevOps YAML pipeline for deploying Terraform infrastructure across multiple environments with approval gates and safety controls.

## Architecture

The pipeline is designed to deploy Terraform configurations from three separate directories which must be deployed in the respective order:
- **Common**: Shared/common infrastructure resources
- **Networking**: Network infrastructure and connectivity
- **Application**: Application-specific infrastructure

## Features

- **Runtime Parameters**: Select your environment (dev/qa/prod), Terraform to deploy (Application/Common/Networking)
- **Approval Gates**: Apply operations require manual approval via ADO Environments
- **Teams Notifications**: Automatic notifications sent to Microsoft Teams when approval is needed and when deployment completes
- **State Management**: Remote state stored in Azure Storage with separate state files per environment
- **Validation Stage**: Automatically validates and checks Terraform formatting
- **Plan Artifacts**: Terraform plans are saved and reused during apply to ensure consistency
- **Safety Controls**: 
  - Manual triggers only (no automatic deployments)
  - Separate stages for validate → plan → apply
  - Plan must succeed before apply can run

## Prerequisites

Before using this pipeline, you need:

1. **Azure Subscription** with permissions to create resources
2. **Azure DevOps Organization and Project**
3. **Self-hosted Azure DevOps Agent or MS hosted agent** (ADO_Agent) with Terraform pre-installed
4. **Azure Storage Account** for Terraform state backend
5. **Azure Service Connection** in ADO configured for your subscription
6. **ADO Environment** named "Terraform-Production" with approval gates

## Setup Instructions

### 1. Create Azure Storage Account for State

```bash
# Set variables
RESOURCE_GROUP="tfstate-rg"
STORAGE_ACCOUNT="tfstate<uniqueid>"  # Must be globally unique
CONTAINER_NAME="tfstate"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --encryption-services blob

# Create blob container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT
```

### 2. Configure Self-Hosted Agent Pool

This pipeline uses a self-hosted agent pool named **ADO_Agent** with Terraform pre-installed.

1. Verify your agent pool exists: **Project Settings** → **Agent Pools** → **ADO_Agent**
2. Ensure the agent is online and has Terraform installed
3. Grant pipeline permission to use the agent pool if required

### 3. Configure Azure Service Connection in ADO

1. Navigate to **Project Settings** → **Service Connections**
2. Click **New Service Connection** → **Azure Resource Manager**
3. Select **Service Principal (automatic)**
4. Choose your subscription and resource group
5. Name it (e.g., `azure-terraform-connection`)
6. Grant access permission to all pipelines

### 4. Create ADO Environment with Approvals

1. Navigate to **Pipelines** → **Environments**
2. Click **New Environment**
3. Name: `Terraform-Production`
4. Add approvers:
   - Click **Approvals and checks**
   - Add **Approvals**
   - Select specific users/groups who can approve
   - Configure timeout and retry settings

### 5. Update Pipeline Variables

Edit `azure-pipelines.yml` and replace the following placeholders:

```yaml
variables:
  - name: serviceConnection
    value: 'azure-terraform-connection'  # Your service connection name
  - name: backendResourceGroup
    value: 'tfstate-rg'  # Your backend resource group
  - name: backendStorageAccount
    value: 'tfstate<uniqueid>'  # Your storage account name
  - name: backendContainerName
    value: 'tfstate'
  - name: teamsWebhookUrl
    value: 'https://your-tenant.webhook.office.com/...'  # Your Teams webhook URL
```

### 7. Add Pipeline to Azure DevOps

1. Navigate to **Pipelines** → **New Pipeline**
2. Select **Azure Repos Git** (or your repo location)
3. Select your repository
4. Choose **Existing Azure Pipelines YAML file**
5. Select `/azure-pipelines.yml`
6. Click **Save** (don't run yet)

## Usage

### Running the Pipeline

1. Go to **Pipelines** and select your Terraform pipeline
2. Click **Run Pipeline**
3. Select parameters:
   - **Terraform Directory**: Choose Application, Common, or Networking
   - **Terraform Action**: Choose plan or apply

### Plan Only (Safe Exploration)

- Select **action: plan**
- Pipeline will validate, plan, and show what would change
- No approval required
- No infrastructure changes made

### Plan + Apply (Actual Deployment)

- Select **action: apply**
- Pipeline will:
  1. Validate Terraform configuration
  2. Generate and publish plan
  3. **PAUSE for manual approval**
  4. Apply changes after approval

## Pipeline Stages

```
┌─────────────────────────────┐
│  Terraform Validate         │
│  - Init backend             │
│  - Validate config          │
│  - Format check             │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│  Terraform Plan             │
│  - Init backend             │
│  - Generate plan            │
│  - Publish plan artifact    │
│  - Display summary          │
│  - Send Teams approval      │
│     notification (if apply) │
└─────────────┬───────────────┘
              │
              ▼ (only if action=apply)
┌─────────────────────────────┐
│  Terraform Apply            │
│     REQUIRES APPROVAL       │
│  - Download plan            │
│  - Init backend             │
│  - Apply saved plan         │
│  - Display summary          │
│  - Send Teams success       │
│     notification            │
└─────────────────────────────┘
```

## Teams Notifications

The pipeline sends rich, actionable notifications to your Microsoft Teams channel:

### Approval Request Notification
When a plan completes and apply is selected, you'll receive:
- **Title**: Terraform Apply Approval Required
- **Environment**: Which Terraform directory (Application/Common/Networking)
- **Requested By**: Who triggered the pipeline
- **Repository & Branch**: Source information
- **Action Buttons**:
  - **Review Plan**: Opens the build to review Terraform plan output
  - **Approve/Reject**: Direct link to approve or reject the deployment

### Success Notification
After a successful apply:
- **Title**: Terraform Apply Completed Successfully
- **Environment**: Which infrastructure was deployed
- **Approved By**: Who approved the deployment
- **State File**: Which state file was updated
- **Action Button**:
  - **View Pipeline Results**: Link to the completed pipeline

These notifications keep your team informed and provide quick access to review and approve infrastructure changes without leaving Teams!

## Security Best Practices

This pipeline implements several security best practices:

1. **No Auto-triggers**: `trigger: none` prevents accidental deployments
2. **Approval Gates**: Human review required before infrastructure changes
3. **Plan Reuse**: Apply uses the exact plan that was reviewed
4. **Separate State Files**: Each environment has isolated state
5. **Service Principal**: Uses managed identity for Azure authentication
6. **Least Privilege**: Service connection should have minimal required permissions
7. **Secure Webhook Storage**: Teams webhook URL stored as a secret in ADO Library

## Troubleshooting

### "Agent not found" or "No agent could be found"
- Verify the agent pool "ADO_Agent" exists in Project Settings → Agent Pools
- Ensure at least one agent in the pool is online
- Check that the pipeline has permission to use the agent pool

### "Terraform command not found"
- Verify Terraform is installed on your self-hosted agent
- Run `terraform --version` on the agent to confirm installation
- Ensure the agent's PATH includes the Terraform binary

### "Backend initialization failed"
- Verify storage account exists and is accessible
- Check service connection has Storage Blob Data Contributor role
- Ensure backend variable values are correct

### "Environment not found"
- Create the environment "Terraform-Production" in ADO
- Grant pipeline permission to access the environment

### Plan/Apply mismatch
- This shouldn't happen as we use plan artifacts
- If it does, re-run from plan stage

### Teams notifications not sending
- Verify the webhook URL is correct and active
- Test the webhook manually using PowerShell or curl
- Check that the webhook connector is still enabled in Teams
- Ensure the pipeline has network access to office.com
- Review pipeline logs for error messages in the PowerShell tasks

### Teams notification sent but not visible
- Check you're looking at the correct Teams channel
- Verify the webhook wasn't removed or disabled
- Some Teams configurations may filter or block incoming webhooks

## Customization

### Add More Environments
Add values to the `terraformDirectory` parameter:

```yaml
parameters:
  - name: terraformDirectory
    values:
      - Application
      - Common
      - Networking
      - Database  # Add new environment
```

## Additional Resources

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure DevOps Terraform Task](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)
- [Terraform State Management](https://www.terraform.io/docs/language/state/index.html)
- [ADO Environments & Approvals](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments)

## Contributing

This is a portfolio project demonstrating DevOps best practices. Feel free to fork and adapt for your own use cases!

