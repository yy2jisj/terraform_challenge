resource "aws_ssm_parameter" "app_config" {
  name  = var.ssm_string_name
  type  = "String"
  value = var.ssm_string_value

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-app-config"
  })
}

resource "aws_ssm_parameter" "app_password" {
  name  = var.ssm_secure_name
  type  = "SecureString"
  value = var.ssm_secure_value

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-app-password"
  })
}
