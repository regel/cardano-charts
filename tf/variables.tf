variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default = ""
}

variable "aad_group_name" {
  description = "Name of the Azure AD group for cluster-admin and Vault access"
  type        = string
  default     = "Cardano Admins"
}

variable "allow_cidr" {
  type        = string
  description = "Allow Vault access from this CIDR address block"
  default = ""
}

variable "location" {
  type        = string
  description = "Location of the resource group"
  default = "West Europe"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name"
  default = ""
}

variable "dns_label" {
  type        = string
  description = "Cardano Relay DNS Label"
  default = ""
}

variable "dns_prefix" {
  type        = string
  description = "Cluster DNS prefix"
  default = ""
}

variable "admin_username" {
  type        = string
  description = "Admin username for Linux cluster nodes"
  default     = "cardano"
}

variable "public_ssh_key" {
  type        = string
  description = "Public SSH key for Linux cluster nodes"
  default     = ""
}

variable "enable_log_analytics_workspace" {
  type        = bool
  description = "Enable log analytics"
  default = false
}

variable "subscription_id" {
  type        = string
  description = "Subscription id"
}

variable "client_id" {
  type        = string
  description = "TF_SP_ID set in setup-rbac helper script"
}

variable "client_secret" {
  type        = string
  description = "TF_SP_SECRET set in setup-rbac script"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Tenant id"
}

variable "velero_client_id" {
  type        = string
  description = "TF_SP_ID set in setup-velero helper script"
}

variable "velero_client_secret" {
  type        = string
  description = "TF_SP_SECRET set in setup-velero script"
  sensitive   = true
}

