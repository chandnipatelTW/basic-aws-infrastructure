resource "aws_cloudwatch_metric_alarm" "kafka_disk_usage" {
  alarm_name                = "Kafka-Low Disk Space"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "DiskSpaceAvailable"
  namespace                 = "System/Linux"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "3"
  alarm_description         = "Alarm for low disk space on Kafka Node."
  alarm_actions             = [ "${aws_sns_topic.blr_data_engg_alerts.arn}" ]
    dimensions = {
      Filesystem= "/dev/xvda1"
      InstanceId = "${aws_instance.kafka.id}"
      MountPath =  "/"
    }
}
