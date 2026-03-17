output "vpc_id" {
  description = "ID of the main VPC."
  value       = aws_vpc.main.id
}

output "external_alb_dns_name" {
  description = "Public DNS name of the external application load balancer."
  value       = aws_lb.external.dns_name
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host."
  value       = aws_instance.bastion.public_ip
}

output "ssm_parameter_paths" {
  description = "Paths of the SSM parameters created for the lab."
  value = [
    aws_ssm_parameter.app_config.name,
    aws_ssm_parameter.app_password.name
  ]
}
