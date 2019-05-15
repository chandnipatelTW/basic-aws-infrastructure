resource "aws_sns_topic" "blr_data_engg_alerts" {
  name = "BLR_DATA_ENGG_ALERTS"
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.blr_data_engg_alerts.arn}  --protocol email --notification-endpoint cpatel@thoughtworks.com"
  }

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.blr_data_engg_alerts.arn}  --protocol email --notification-endpoint pdogra@thoughtworks.com"
  }

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.blr_data_engg_alerts.arn}  --protocol email --notification-endpoint kadarsh@thoughtworks.com"
  }

}
