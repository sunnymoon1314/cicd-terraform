# 00. Create an SNS topic.
resource "aws_sns_topic" "user_updates" {
  name = "soon-updates-topic-${var.env}"
}
