variable "aws_region" {
    description = "AWS Region"
    type = string
    default = "us-east-1"
}

variable "environment" {
    description = "Environment name (dev, stage, prod)"
    type = string
}