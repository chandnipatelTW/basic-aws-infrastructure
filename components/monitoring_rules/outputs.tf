output "lambda_role_for_sns_and_logs_send" {
  description = "SNS and CloudWatch can access to this Lambda role applied functions."
  value       = "${aws_iam_role.emr_rule_formatter_lambda_role.name}"
}