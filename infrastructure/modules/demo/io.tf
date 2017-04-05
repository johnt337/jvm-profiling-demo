# instance
variable "ami"                                {}
variable "instance_type"                      { default = "t2.micro" }
variable "iam_instance_profile"               {}
variable "role"                               { default = "demo" }
variable "ebs_optimized"                      { default = true }
variable "root_volume_type"                   { default = "gp2" }
variable "root_volume_size"                   { default = 10 }
variable "root_volume_encrypted"              { default = true }
variable "root_volume_delete_on_termination"  { default = false }
variable "var_volume_path"                    { default = "/dev/xvdb" }
variable "var_volume_type"                    { default = "gp2" }
variable "var_volume_size"                    { default = 100 }
variable "var_volume_encrypted"               { default = false }
variable "var_volume_delete_on_termination"   { default = false }
variable "data_volume_path"                   { default = "/dev/xvdc" }
variable "data_volume_type"                   { default = "gps2" }
variable "data_volume_size"                   { default = 10 }
variable "data_volume_encrypted"              { default = false }
variable "data_volume_delete_on_termination"  { default = false }

# deployment
variable "version"                            {}
variable "environment"                        {}
variable "app_name"                           {}
variable "site_name"                          {}
variable "region"                             {}
variable "aws_account_id"                     {}
variable "ssh_key"                            {}
variable "ssh_key_name"                       {}
variable "password"                           {}
variable "customer"                           {}
variable "consortium"                         {}
variable "dns_domain"                         {}
variable "associate_public_ip"                { default = false }
variable "vpc_security_group_ids"             {}
variable "subnet_id"                          {}
variable "aws_tag_version"                    {}
variable "r53zone_id"                         {}
variable "configuration_bucket"               {}

# instance
output "ami"                                  { value="${var.ami}" }
output "instance_type"                        { value="${var.instance_type}" }
output "iam_instance_profile"                 { value="${var.iam_instance_profile}" }
output "role"                                 { value="${var.role}" }
output "ebs_optimized"                        { value="${var.ebs_optimized}" }
output "root_volume_type"                     { value="${var.root_volume_type}" }
output "root_volume_size"                     { value="${var.root_volume_size}" }
output "root_volume_encrypted"                { value="${var.root_volume_encrypted}" }
output "root_volume_delete_on_termination"    { value="${var.root_volume_delete_on_termination}" }
output "var_volume_path"                      { value="${var.var_volume_path}" }
output "var_volume_type"                      { value="${var.var_volume_type}" }
output "var_volume_size"                      { value="${var.var_volume_size}" }
output "var_volume_encrypted"                 { value="${var.var_volume_encrypted}" }
output "var_volume_delete_on_termination"     { value="${var.var_volume_delete_on_termination}" }
output "data_volume_path"                     { value="${var.data_volume_path}" }
output "data_volume_type"                     { value="${var.data_volume_type}" }
output "data_volume_size"                     { value="${var.data_volume_size}" }
output "data_volume_encrypted"                { value="${var.data_volume_encrypted}" }
output "data_volume_delete_on_termination"    { value="${var.data_volume_delete_on_termination}" }
output "instance_dns"                         { value="${aws_route53_record.demo.name}" }
output "instance_id"                          { value="${aws_instance.demo.id}" }
output "instance_public_ip"                   { value="${aws_instance.demo.public_ip}" }
output "instance_private_ip"                  { value="${aws_instance.demo.private_ip}" }

# deployment
output "version"                              { value="${var.version}" }
output "environment"                          { value="${var.environment}" }
output "app_name"                             { value="${var.app_name}" }
output "site_name"                            { value="${var.site_name}" }
output "aws_account_id"                       { value="${var.aws_account_id}" }
output "region"                               { value="${var.region}" }
output "ssh_key"                              { value="${var.ssh_key}" }
output "ssh_key_name"                         { value="${var.ssh_key_name}" }
output "password"                             { value="${var.password}" }
output "customer"                             { value="${var.customer}" }
output "consortium"                           { value="${var.consortium}" }
output "dns_domain"                           { value="${var.dns_domain}" }
output "associate_public_ip"                  { value="${var.associate_public_ip}" }
output "vpc_security_group_ids"               { value="${var.vpc_security_group_ids}" }
output "subnet_id"                            { value="${var.subnet_id}" }
output "node_name"                            { value="${format("%s-%s-%s", var.app_name, var.role, var.environment)}" }
output "aws_tag_version"                      { value="${var.aws_tag_version}" }
output "r53zone_id"                           { value="${var.r53zone_id}" }
output "configuration_bucket"                 { value="${var.configuration_bucket}" }
