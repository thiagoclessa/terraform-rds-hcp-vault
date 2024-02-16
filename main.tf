provider "vault" {
  # HCP Vault Configuration options
  address = var.vault_address
  namespace = var.vault_namespace
  auth_login {
    path = "auth/userpass/login/${var.login_username}"
    namespace = var.vault_namespace
    
    parameters = {
      password = var.login_password
    }
  } 
}

resource "vault_mount" "db" {
  path = "postgres"
  type = "database"
}

resource "vault_database_secrets_mount" "db" {
  path = "db"

  postgresql {
    name              = "postgres"
    username          = aws_db_instance.dap-education.username
    password      = var.db_password
    connection_url    = "postgresql://{{username}}:{{password}}@${aws_db_instance.RDS_VKPR}:${aws_db_instance.RDS_VKPR.port}/postgres?sslmode=disable"
    verify_connection = true
    allowed_roles = [
      "dev2","readWrite","readOnly"
    ]
  }
}

resource "vault_database_secret_backend_role" "readOnly" {
  name    = "readOnly"
  default_ttl = 900
  max_ttl = 2700
  backend = vault_database_secrets_mount.db.path
  db_name = vault_database_secrets_mount.db.postgresql[0].name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
  ]
}

resource "vault_database_secret_backend_role" "readWrite" {
  name    = "readWrite"
  default_ttl = 600
  max_ttl = 1200
  backend = vault_database_secrets_mount.db.path
  db_name = vault_database_secrets_mount.db.postgresql[0].name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT ALL ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
  ]
}

resource "vault_generic_secret" "example-kv-update" {
  path = "kv/app_info"

  data_json = <<EOT
{
  "username":   "tfc-updated",
  "password": "new-from-tfc"
}
EOT
}

resource "vault_generic_secret" "example-kv-v2-update" {
  path = "kv-v2/app_info"

  data_json = <<EOT
{
  "username":   "tfc-updated",
  "password": "new-from-tfc"
}
EOT
}

resource "aws_db_instance" "RDS_VKPR" {
    allocated_storage = var.allocated_storage
    engine = var.engine
    engine_version = var.engine_version
    instance_class = var.instance_class
    db_name = var.dbname
    username = var.username
    password = var.password
    skip_final_snapshot = var.skip_final_snapshot
    final_snapshot_identifier = "${var.dbname}-snapshot"
    tags = {
    name = "VKPR-RDS"
  }
}
