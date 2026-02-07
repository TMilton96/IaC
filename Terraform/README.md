# Terraform Configuration Module

This Terraform module contains Business logic to provide the following outputs:

- Standard Azure Resource Names
- Azure Tags

## Modules
In these working examples there are 3 different modules which are deployed in the respective order:

Common - For deploying things like resource groups and key vaults which can then be used for project specific deployments

Networking - For deploying any base networking related infrastructure like VNets, Subnets, NSGs, and optionally Public IPs, or NICs

Applications - For deploying application related infrastructure such as VMs, App Services, Databases, or any other compute resources


## How to Use

To use the module you only need to provide a few parameters. An example is below:

```terraform
module "config" {
  source           = "/path/to/configuration/module"
  environment      = "dev"
  region           = "eastus"
  point_of_contact = "my-project-email@domain.com"
}
```

## Requirements

|Name|Version|
|--|--|
|terraform|>= 0.13.0|

## Inputs

|Name|Description|Type|Default|Required|
|--|--|--|--|--|
|project|The project this terraform resource is associated to|`string`|`""`|Yes|
|business_unit|The Business Unit used for cost allocation.
|environment|The type of environment used|`string`|`"dev"`|Yes|
|region|The region used for conventions and tagging. Must use one of the approved regions|`string`|`""`|Yes|
|point_of_contact|The email address for the owner of the resource, recommended to be a distribution list for the project|`string`|`""`|Yes|

## Outputs

|Name|Description|
|--|--|
|azure_tags|A default map of tags that adheres to standards and can be used for Azure resources|
|azure_**resource_name**|Multiple outputs of common resource names that adhere to standards. See [Outputs](./outputs.tf) for full list of resource names supported|


## Vars

The vars directory hold sub directories for each environment. Inside of each environment sub directory are tfvars files for the respective deployment type: app, common, and networking.
sdf
