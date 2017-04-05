data "template_file" "password" {
  template = "${file("${ path.module }/../../../services/containers/demo-bastion/conf/password")}"
}

data "template_file" "ssh_private_key" {
  template = "${file("${ path.module }/../../../services/containers/demo-bastion/conf/demo.pem")}"
}

data "template_file" "ssh_public_key" {
  template = "${file("${ path.module }/../../../services/containers/demo-bastion/conf/demo.pem.pub")}"
}

data "template_file" "demo_instance_vars" {
  template = "${file("${ path.module }/../../demo_vars.tf.json")}"
}

data "template_file" "deployment_instance_vars" {
  template = "${file("${ path.module }/../../deployment_vars.tf.json")}"
}

data "template_file" "user-data" {
  template               = "${ file("${ path.module }/ignition.yaml.tpl") }"
  vars {
    iam_instance_profile = "${ var.demo_instance["iam_instance_profile"] }"
    role                 = "${ var.demo_instance["role"] }"

    ## disk configs
    root_volume_type     = "${ var.demo_instance["root_volume_type"] }"
    root_volume_size     = "${ var.demo_instance["root_volume_size"] }"
    var_volume_path      = "${ var.demo_instance["var_volume_path"] }"
    var_volume_type      = "${ var.demo_instance["var_volume_type"] }"
    var_volume_size      = "${ var.demo_instance["var_volume_size"] }"
    data_volume_path     = "${ var.demo_instance["data_volume_path"] }"
    data_volume_type     = "${ var.demo_instance["data_volume_type"] }"
    data_volume_size     = "${ var.demo_instance["data_volume_size"] }"

    # deployment configs
    version              = "${ var.deployment["version"] }"
    environment          = "${ var.deployment["environment"] }"
    app_name             = "${ var.deployment["app_name"] }"
    site_name            = "${ var.deployment["site_name"] }"
    region               = "${ var.deployment["region"] }"
    aws_account_id       = "${ var.deployment["aws_account_id"] }"
    ssh_key              = "${ data.template_file.ssh_public_key.rendered }"
    password             = "${ data.template_file.password.rendered }"
    customer             = "${ var.deployment["customer"] }"
    consortium           = "${ var.deployment["consortium"] }"
    dns_domain           = "${ var.deployment["dns_domain"] }"
    aws_tag_version      = "${ var.deployment["aws_tag_version"] }"
    s3_util_version      = "${ var.deployment["s3_util_version"] }"
    r53zone_id           = "${ var.deployment["r53zone_id"] }"
    configuration_bucket = "${ format("%s-%s-%s-%s",var.deployment["customer"],var.deployment["site_name"],var.deployment["region"],var.deployment["aws_account_id"]) }"
    registry             = "${ var.deployment["registry"] }"
    access_key           = "${ var.deployment["access_key"] }"
    fqdn                 = "${ var.deployment["fqdn"] }"

  }
}

resource "null_resource" "generator" {
  triggers {
    template             = "${ md5(data.template_file.user-data.rendered) }"
    demo                 = "${ md5(data.template_file.demo_instance_vars.rendered) }"
    deployment           = "${ md5(data.template_file.deployment_instance_vars.rendered) }"
  }

  provisioner "local-exec" {
    command              = "echo '${ data.template_file.user-data.rendered }' > ignition.yaml"
  }
}
