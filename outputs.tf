output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.dap-education.address
  sensitive   = false
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.dap-education.port
  sensitive   = false
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.dap-education.username
  sensitive   = true
}

