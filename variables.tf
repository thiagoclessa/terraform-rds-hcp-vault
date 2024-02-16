variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}

variable "vault_address" {
    description = "url to use to access vault"
  }

variable "vault_add_address" {
    description = "will add vault_address to env var VAULT_ADDR if set to true"
    default = true
  }

variable "vault_namespace" {
    description = "namespace to use"
    default = "/admin"
}

variable "login_username" {
    description = "auth username"
}

variable "login_password" {
    description = "auth password"
}
