variable "environment" {type = string}
variable "terraform_script_version" {type = string}
variable "location" {type = string}
variable "storage_containers" {
  description = "Default blob storage containers used by SAEB Platform"
  type        = list(string)
}

# These variables need to be assigned in TeamCity build step. Credentials for Adobe Analytics and Statscan.
variable "aa_cient_id" {type = string}
variable "aa_cient_secret" {type = string}
variable "aa_global_company_id" {type = string}
variable "aa_org_id" {type = string}
variable "aa_private_key" {type = string}
variable "aa_report_suite_id" {type = string}
variable "aa_subject_account" {type = string}
variable "statscan_username" {type = string}
variable "statscan_password" {type = string}