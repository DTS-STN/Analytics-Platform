# saeb
# Analytics-Platform
Repository for SAEB Analytics Platform configuration

This repository will store the TeamCity and Terraform scripts to be able to deploy the SAEB Analytics Platform configurations into Azure with TeamCity.

It will leverage the following repositories to bring the code into the Azure resources respectively that will be used to execute the "data pipelines"

- [AP-Databricks](https://github.com/DTS-STN/AP-Databricks)
- [AP-DataFactory](https://github.com/DTS-STN/AP-DataFactory)
- [AP-Synapse](https://github.com/DTS-STN/AP-Synapse)

Inital version Terraform scripts are included to build the Azure services. These scripts will be executed using Teamcit pipeline (https://teamcity.dts-stn.com/admin/editProject.html?projectId=saeb_dev). 
This teamcity pipeline has the trigger to run every time content of the Main branch changes. Currently this trigger is disabled since we are still in the development mode. 

