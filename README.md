# saeb
# Analytics-Platform
Repository for SAEB Analytics Platform configuration

This repository will store the TeamCity and Terraform scripts to be able to deploy the SAEB Analytics Platform configurations into Azure with TeamCity.

It will leverage the following repositories to bring the code into the Azure resources respectively that will be used to execute the "data pipelines"

- [AP-Databricks](https://github.com/DTS-STN/AP-Databricks)
- [AP-DataFactory](https://github.com/DTS-STN/AP-DataFactory)
- [AP-Synapse](https://github.com/DTS-STN/AP-Synapse)

Inital version Terraform scripts are included. Following are the files
- variables.tf
- terraform.tfvars
- providers.tf
- main.tf
