variable "environment" {type = string}
variable "terraform_script_version" {type = string}
variable "location" {type = string}
variable "storage_containers" {
  description = "Default blob storage containers used by SAEB Platform"
  type        = list(string)
}

variable "kv-key-permissions-full" {
  type        = list(string)
  description = "List of full key permissions, must be one or more from the following: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify and wrapKey."
  default     = [ "backup", "create", "decrypt", "delete", "encrypt", "get", "import", "list", "purge", 
                  "recover", "restore", "sign", "unwrapKey","update", "verify", "wrapKey" ]
}

variable "kv-secret-permissions-full" {
  type        = list(string)
  description = "List of full secret permissions, must be one or more from the following: backup, delete, get, list, purge, recover, restore and set"
  default     = [ "backup", "delete", "get", "list", "purge", "recover", "restore", "set" ]
}

variable "kv-storage-permissions-full" {
  type        = list(string)
  description = "List of full storage permissions, must be one or more from the following: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas and update"
  default     = [ "backup", "delete", "deletesas", "get", "getsas", "list", "listsas", 
                  "purge", "recover", "regeneratekey", "restore", "set", "setsas", "update" ]
}

variable "kv-key-permissions-read" {
  type        = list(string)
  description = "List of read key permissions, must be one or more from the following: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify and wrapKey"
  default     = [ "get", "list" ]
}

variable "kv-secret-permissions-read" {
  type        = list(string)
  description = "List of full secret permissions, must be one or more from the following: backup, delete, get, list, purge, recover, restore and set"
  default     = [ "get", "list" ]
}

variable "kv-storage-permissions-read" {
  type        = list(string)
  description = "List of read storage permissions, must be one or more from the following: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas and update"
  default     = [ "get", "getsas", "list", "listsas" ]
}

# These variables need to be assigned in TeamCity build step. Credentials for Adobe Analytics and Statscan.
variable "aa_client_id" {type = string}
variable "aa_client_secret" {type = string}
variable "aa_global_company_id" {type = string}
variable "aa_org_id" {type = string}
variable "aa_private_key" {type = string}
variable "aa_report_suite_id" {type = string}
variable "aa_subject_account" {type = string}
variable "statscan_username" {type = string}
variable "statscan_password" {type = string}

# TODO: make one variable for secrets:
# variable "secrets" {
#   type = map(object({
#     value = string
#   }))
#   description = "Define Azure Key Vault secrets"
#   default = {}
# }
