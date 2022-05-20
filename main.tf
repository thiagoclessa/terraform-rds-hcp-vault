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
    name = "${var.prefix}-dapvpc-${var.region}"
    owner = var.prefix
    region = var.hashi-region
    purpose = var.purpose
    ttl = var.ttl
    Department = var.Department
    Billable = var.Billable
  }
}

resource "aws_db_subnet_group" "dap-vpc" {
  name       = "dap-db-subnet-group"
  subnet_ids = module.vpc.public_subnets

  tags = {
    name = "${var.prefix}-dbsubnetgroup-${var.region}"
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
    name = "${var.prefix}-dbsecgroup-${var.region}"
    owner = var.prefix
    region = var.hashi-region
    purpose = var.purpose
    ttl = var.ttl
    Department = var.Department
    Billable = var.Billable
  }
}

resource "aws_db_parameter_group" "education" {
  name   = "education"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
  tags = {
    name = "${var.prefix}-rdsdbparameters-${var.region}"
    owner = var.prefix
    region = var.hashi-region
    purpose = var.purpose
    ttl = var.ttl
    Department = var.Department
    Billable = var.Billable
  }
}

resource "aws_db_instance" "education" {
  identifier             = "education"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "13.1"
  username               = "edu"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.education.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
