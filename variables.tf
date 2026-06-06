variable "instance_type" {
  description = "EC2インスタンスのタイプ。運用要件に応じて変更可能。"
  type        = string
  default     = "t2.micro"
}
