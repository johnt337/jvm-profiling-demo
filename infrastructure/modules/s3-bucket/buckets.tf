resource "aws_s3_bucket" "site_bucket" {
   bucket = "${var.site_name}"
   force_destroy = true
}
