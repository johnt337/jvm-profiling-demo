# Standalone s3 bucket
## Usage

### deployment.tf file
```hcl
module "s3" {
  source    = "git::ssh://git@github.com/infrastructure/modules/s3-bucket.git"
  site_name = "${format("%s-%s-%s-%s",var.deployment["customer"],var.deployment["site_name"],var.deployment["region"],var.deployment["aws_account_id"])}"
}
```

### terraform get the modules

```bash
$ terraform get
```

### terraform apply

```bash
$ terraform apply
```

