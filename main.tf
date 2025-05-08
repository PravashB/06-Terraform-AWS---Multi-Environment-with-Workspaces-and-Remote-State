resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

resource "aws_s3_bucket" "env_bucket" {
  bucket = "sample-app-${var.environment}-pro-${random_integer.suffix.result}"

  tags = {
    Name        = "SampleApp-${var.environment}-Bucket"
    Environment = var.environment
  }
}
