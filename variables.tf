variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type (t3.micro is Free Tier eligible in ap-south-1)"
  type        = string
  default     = "t3.micro"
}
