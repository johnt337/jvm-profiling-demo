# to support compatibility with containers and what seems some "weirdness" with terraform in a container context.
# we source the AWS_.... security enviroment variables via iam profile (see templates/config.tpl)
# as compared to using config variable "aws_access_key" {} and TF_VAR_aws_access_key.
# https://github.com/hashicorp/terraform/issues/5256

provider "aws" {}

data "template_file" "password" {
  template = "${file("../services/containers/demo-bastion/conf/password")}"
}

data "template_file" "ssh_private_key" {
  template = "${file("../services/containers/demo-bastion/conf/demo.pem")}"
}

data "template_file" "ssh_public_key" {
  template = "${file("../services/containers/demo-bastion/conf/demo.pem.pub")}"
}

# for the purposes of getting an md5 checksum and ignoring those vars
data "template_file" "compose_file" {
  template = "${file("../docker-compose.yml")}"
  vars {
    REGISTRY   = "${var.deployment["registry"]}"  
    ACCESS_KEY = ""
    FQDN       = ""
  }
}

resource "aws_key_pair" "authorized_key" {
  depends_on = ["data.template_file.ssh_public_key"]
  key_name   = "demo" 
  public_key = "${data.template_file.ssh_public_key.rendered}"
}

module "s3" {
  source    = "./modules/s3-bucket"
  site_name = "${format("%s-%s-%s-%s",var.deployment["customer"],var.deployment["site_name"],var.deployment["region"],var.deployment["aws_account_id"])}"
}

resource "aws_security_group" "demo" {
  name = "${format("%s-%s-%s-%s",var.deployment["customer"],var.deployment["site_name"],var.deployment["region"],var.deployment["aws_account_id"])}"
  description = "Allow access to resources for jvm profiling demo..."
  vpc_id = "${var.deployment["vpc_id"]}"
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "8"
    to_port     = "0"
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "22"
    to_port   = "22"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "80"
    to_port   = "80"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "443"
    to_port   = "443"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "20022"
    to_port   = "20022"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {Name = "${format("%s-%s-%s-%s",var.deployment["customer"],var.deployment["site_name"],var.deployment["region"],var.deployment["aws_account_id"])}"}
}

resource "aws_iam_role" "demo-server" {
    name = "demo-server"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "demo-server" {
    name = "demo-server"
    roles = ["${aws_iam_role.demo-server.name}"]
}

resource "aws_iam_role_policy" "demo-server-ec2-tag" {
    name = "demo-server-ec2-tag"
    role = "${aws_iam_role.demo-server.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeTags",
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "demo-server-s3" {
    name = "demo-server-s3"
    role = "${aws_iam_role.demo-server.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1456432940079",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectTagging",
                "s3:GetObjectVersion",
                "s3:GetObjectVersionTagging",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:ListBucketVersions",
                "s3:ListMultipartUploadParts",
                "s3:PutObject",
                "s3:PutObjectTagging"
            ],
            "Resource": [
                "${module.s3.arn}",
                "${module.s3.arn}/",
                "${module.s3.arn}/*"
            ]
        }
    ]
}
EOF
}

resource "null_resource" "sync_docker_files" {
  depends_on = ["module.s3"]
  triggers = {
    template = "{ md5(data.template_file.compose_file.rendered) }"
  }
  provisioner "local-exec" {
    command = "docker run --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -v $PWD/../:/data/demo floccus/s3:${var.deployment["s3_util_version"]} put -b ${format("%s-%s-%s-%s",var.deployment["customer"],var.deployment["site_name"],var.deployment["region"],var.deployment["aws_account_id"])} -s /data/demo/docker-compose.yml -v"
  } 
  provisioner "local-exec" {
    command = "docker run --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -v $PWD/../:/data/demo floccus/s3:${var.deployment["s3_util_version"]} put -b ${format("%s-%s-%s-%s",var.deployment["customer"],var.deployment["site_name"],var.deployment["region"],var.deployment["aws_account_id"])} -s /data/demo/services -v"
  } 
}

module "demo" {
  source                            = "./modules/demo"

  # instance overrides
  ## base configs
  ami                               = "${var.amis[format("%s.%s",var.deployment["region"],var.demo_instance["ami"])]}"
  instance_type                     = "${var.demo_instance["instance_type"]}"
  iam_instance_profile              = "${var.demo_instance["iam_instance_profile"]}"
  role                              = "${var.demo_instance["role"]}"
  ebs_optimized                     = "${var.demo_instance["ebs_optimized"]}"

  ## disk configs
  root_volume_type                  = "${var.demo_instance["root_volume_type"]}"
  root_volume_size                  = "${var.demo_instance["root_volume_size"]}"
  root_volume_encrypted             = "${var.demo_instance["root_volume_encrypted"]}"
  root_volume_delete_on_termination = "${var.demo_instance["root_volume_delete_on_termination"]}"
  var_volume_path                   = "${var.demo_instance["var_volume_path"]}"
  var_volume_type                   = "${var.demo_instance["var_volume_type"]}"
  var_volume_size                   = "${var.demo_instance["var_volume_size"]}"
  var_volume_encrypted              = "${var.demo_instance["var_volume_encrypted"]}"
  var_volume_delete_on_termination  = "${var.demo_instance["var_volume_delete_on_termination"]}"
  data_volume_path                  = "${var.demo_instance["data_volume_path"]}"
  data_volume_type                  = "${var.demo_instance["data_volume_type"]}"
  data_volume_size                  = "${var.demo_instance["data_volume_size"]}"
  data_volume_encrypted             = "${var.demo_instance["data_volume_encrypted"]}"
  data_volume_delete_on_termination = "${var.demo_instance["data_volume_delete_on_termination"]}"
  associate_public_ip               = "${var.demo_instance["associate_public_ip"]}"
  subnet_id                         = "${var.demo_instance["subnet_id"]}"
  vpc_security_group_ids            = "${aws_security_group.demo.id}"

  # deployment configs
  version                           = "${var.deployment["version"]}"
  environment                       = "${var.deployment["environment"]}"
  app_name                          = "${var.deployment["app_name"]}"
  site_name                         = "${var.deployment["site_name"]}"
  region                            = "${var.deployment["region"]}"
  aws_account_id                    = "${var.deployment["aws_account_id"]}"
  ssh_key_name                      = "${aws_key_pair.authorized_key.key_name}"
  ssh_key                           = "${data.template_file.ssh_public_key.rendered}"
  password                          = "${data.template_file.password.rendered}"
  customer                          = "${var.deployment["customer"]}"
  consortium                        = "${var.deployment["consortium"]}"
  dns_domain                        = "${var.deployment["dns_domain"]}"
  aws_tag_version                   = "${var.deployment["aws_tag_version"]}"
  r53zone_id                        = "${var.deployment["r53zone_id"]}"
  configuration_bucket              = "${format("%s-%s-%s-%s",var.deployment["customer"],var.deployment["site_name"],var.deployment["region"],var.deployment["aws_account_id"])}"
}


