output "vpc_id" {
  value = "${var.deployment["vpc_id"]}"
}

output "site_name" {
  value = "${var.deployment["site_name"]}"
}

output "deployment_version" {
  value = "${var.deployment["version"]}"
}

output "demo_ami_name" {
  value = "${var.demo_instance["ami"]}"
}

output "demo_module_ami_id" {
  value = "${module.demo.ami}"
}

output "demo_instance_dns" {
  value = "${module.demo.instance_dns}"
}

output "demo_public_ip" {
  value = "${module.demo.instance_public_ip}"
}

output "demo_private_ip" {
  value = "${module.demo.instance_private_ip}"
}

output "demo_asg_group" {
  value = "${var.asgs["demo"]}"
}

output "backup_ssh_key_name" {
  value = "${aws_key_pair.authorized_key.key_name}"
}

output "backup_ssh_key_pub_signature" {
  value = "${data.template_file.ssh_public_key.rendered}"
}

