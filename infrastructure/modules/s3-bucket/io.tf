variable "site_name"            {}

output "site_name"              { value="${site_name}" }
output "id"                     { value="${aws_s3_bucket.site_bucket.id}" }
output "arn"                    { value="${aws_s3_bucket.site_bucket.arn}" }
