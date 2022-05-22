variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}

variable "prefix" {
  description = "used to associate resources with a person"
  default = "dpeacock"
}

#variable "ami_id_value" {
 # description = "Value to use for the ami_id"
#}

variable "owner" {
  default = "dpeacock"
  description = "person from HC that deployed the resource"
}

variable "hashi-region" {
  default = "nymetro"
  description = "HC region that the owner belongs to"
}

variable "purpose" {
  default = "demo"
  description = "what the resource is for"
} 

variable "ttl" {
  default = "96"
  description = "time to live before reaper should delete"
}

variable "Department" {
  description = "the department the resource is for"
  default = "test"
    }

variable "Billable" {
  description = "to bill or not to bill"
  default = "no"
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
