variable "cohort" {
  description = "Training cohort, eg: london-summer-2018"
}

variable "aws_region" {
  description = "Region in which to build resources."
}

variable "sns_alert_topic_arn" {
  description = "Arn to send group alert"
  default = "arn:aws:sns:ap-southeast-1:618886044591:free2wheeler-alarms-kafka"
}