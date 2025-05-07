output "environment_bucket_name" {
  description = "The name of the environment-specific S3 bucket"
  value       = aws_s3_bucket.env_bucket.id
}
