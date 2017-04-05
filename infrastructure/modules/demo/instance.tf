# Template file for GETTING instance user data file
data "template_file" "user-data" {
  template = "${file("./templates/userdata/ignition.json")}"
  vars {
    var_volume_path      = "${var.var_volume_path}"
    data_volume_path     = "${var.data_volume_path}"
    site_name            = "${var.site_name}"
    role                 = "${var.role}"
    environment          = "${var.environment}"
    iam_instance_profile = "${var.iam_instance_profile}"
    version              = "${var.version}"

    aws_account_id       = "${var.aws_account_id}"
    ssh_key_name         = "${var.ssh_key_name}"
    ssh_key              = "${var.ssh_key}"
    password             = "${var.password}"
    environment          = "${var.environment}"
    customer             = "${var.customer}"
    consortium           = "${var.consortium}"
    dns_domain           = "${var.dns_domain}"
    role                 = "${var.role}"
    node_name            = "${format("%s-%s-%s", var.site_name, var.role, var.environment)}"
    aws_tag_version      = "${var.aws_tag_version}"
    bucket               = "${var.configuration_bucket}"
  }
}

resource "aws_instance" "demo" {
    depends_on                  = ["data.template_file.user-data"]
    ami                         = "${var.ami}"
    instance_type               = "${var.instance_type}"
    iam_instance_profile        = "${var.iam_instance_profile}"
    key_name                    = "${var.ssh_key_name}"
    associate_public_ip_address = "${var.associate_public_ip}"
    vpc_security_group_ids      = ["${var.vpc_security_group_ids}"]
    user_data                   = "${data.template_file.user-data.rendered}"
    ebs_optimized               = "${var.ebs_optimized}"
    subnet_id                   = "${var.subnet_id}"

    # /
    root_block_device {
      volume_type               = "${var.root_volume_type}"
      volume_size               = "${var.root_volume_size}"
      delete_on_termination     = "${var.root_volume_delete_on_termination}"
    }

    # docker /var/lib/docker
    ebs_block_device {
      device_name               = "${var.var_volume_path}"
      volume_type               = "${var.var_volume_type}"
      volume_size               = "${var.var_volume_size}"
      encrypted                 = "${var.var_volume_encrypted}"
      delete_on_termination     = "${var.var_volume_delete_on_termination}"
    }

    # docker /mnt
    ebs_block_device {
      device_name               = "${var.data_volume_path}"
      volume_type               = "${var.data_volume_type}"
      volume_size               = "${var.data_volume_size}"
      encrypted                 = "${var.data_volume_encrypted}"
      delete_on_termination     = "${var.data_volume_delete_on_termination}"
    }

    lifecycle {
      create_before_destroy     = false
    }
}

# resource record set resource
resource "aws_route53_record" "demo" {
  depends_on = ["aws_instance.demo"]
  name       = "${format("%s-%s.%s", var.site_name, var.role, var.dns_domain)}"
  zone_id    = "${var.r53zone_id}"
  type       = "A"
  ttl        = "30"
  records    = ["${aws_instance.demo.public_ip}"]
}
