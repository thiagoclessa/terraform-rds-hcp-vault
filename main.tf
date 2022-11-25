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
    #host       = aws_db_instance.education.address
    #port          = aws_db_instance.education.port
    connection_url    = "postgresql://{{username}}:{{password}}@${aws_db_instance.dap-education.address}:${aws_db_instance.dap-education.port}/postgres?sslmode=disable"
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

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "dap-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    name = "dap-vpc"
    owner = var.prefix
    region = var.hashi-region
    purpose = var.purpose
    ttl = var.ttl
    Department = var.Department
    Billable = var.Billable
  }
}

resource "aws_db_subnet_group" "dap-edu" {
  name       = "dap-db-subnet-group"
  subnet_ids = module.vpc.public_subnets

  tags = {
    name = "dap-dbsubnetgroup"
    owner = var.prefix
    region = var.hashi-region
    purpose = var.purpose
    ttl = var.ttl
    Department = var.Department
    Billable = var.Billable
  }
}

resource "aws_security_group" "rds" {
  name   = "dap_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "dap-dbsecgroup"
    owner = var.prefix
    region = var.hashi-region
    purpose = var.purpose
    ttl = var.ttl
    Department = var.Department
    Billable = var.Billable
  }
}

resource "aws_db_parameter_group" "dap-education" {
  name   = "dap-education"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
  tags = {
    name = "dap-rdsdbparameters"
    owner = var.prefix
    region = var.hashi-region
    purpose = var.purpose
    ttl = var.ttl
    Department = var.Department
    Billable = var.Billable
  }
}

resource "aws_db_instance" "dap-education" {
  identifier             = "dap-education"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version       = "13.7"
  username               = "rootedu"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.dap-edu.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.dap-education.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
