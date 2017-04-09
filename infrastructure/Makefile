############################################################################################### 
############################################################################################### 
## While most of this could have easily been included in one of the tf.json files,
## it seems easier to set as env vars. TF will auto merge the maps below with its corresponding
## maps defined in the tf.json files. No need to customize tf config files....
############################################################################################### 
############################################################################################### 

###############################################################################################
######################### EDIT BELOW IF DESIRED, OR EXPORT THESE VARS #########################
###############################################################################################
PATH=${PWD}/fuze/bin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin
#
# aws environment
AWS_DEFAULT_REGION      ?= us-east-1
AWS_ACCOUNT_ID          ?= 012345678910
AWS_DEFAULT_VPC_ID      ?= vpc-123abc45
AWS_DEFAULT_SUBNET_ID   ?= subnet-12ab3c4d
AWS_DEFAULT_R53_ZONE    ?= my.demo.com
AWS_DEFAULT_R53_ZONE_ID ?= A1BCD2E3FGHI4J
export AWS_DEFAULT_REGION AWS_ACCOUNT_ID AWS_DEFAULT_VPC_ID AWS_DEFAULT_SUBNET_ID AWS_DEFAULT_R53_ZONE AWS_DEFAULT_R53_ZONE_ID

#
# terraform environment
# override user specific portions of the deployment map
TF_VAR_deployment={aws_account_id="${AWS_ACCOUNT_ID}",dns_domain="${AWS_DEFAULT_R53_ZONE}",r53zone_id="${AWS_DEFAULT_R53_ZONE_ID}",vpc_id="${AWS_DEFAULT_VPC_ID}",registry="${REGISTRY}",access_key="${ACCESS_KEY}",fqdn="${FQDN}"}

# override user specific portions of the demo_instance map
TF_VAR_demo_instance={subnet_id="${AWS_DEFAULT_SUBNET_ID}"}

export TF_VAR_deployment TF_VAR_demo_instance TF_REGISTRY
# cli overrides
args ?= 

###############################################################################################
######################### NO NEED TO EDIT BELOW ###############################################
###############################################################################################
infra-all: build-tools pre-render-ignition-yaml build-infra

build-tools: 
	@if [ ! -d ${PWD}/fuze ]; then git clone --branch v0.1.0 https://github.com/coreos/container-linux-config-transpiler fuze; fi
	@if [ ! -f ${PWD}/fuze/bin/ct ]; then cd fuze && ./build; else echo "tools up-to-date"; fi 
	@echo "!!!!!!!!!!! TOOLS BUILT !!!!!!!!!!!"

pre-render-ignition-yaml: infrastructure/templates/userdata/ignition.yaml.tpl infrastructure/deployment_vars.tf.json infrastructure/demo_vars.tf.json
	# this it to avoid fuze failing because we have TF vars defined for paths in the file
	@echo "Rendering environment with ACCESS_KEY=${ACCESS_KEY}..."
	@cp -f infrastructure/{deployment,demo}_vars.tf.json infrastructure/templates/userdata/
	@cd infrastructure/templates/userdata && terraform apply 
	@rm -f infrastructure/templates/userdata/{deployment,demo}_vars.tf.json
	@echo "!!!!!!!!!!! PRE-RENDERED IGNITION INPUT !!!!!!!!!!!"

render-ignition-fuze: infrastructure/templates/userdata/ignition.yaml build-tools pre-render-ignition-yaml
	@cat $< | ct -pretty 1> /dev/null
	@cat $< | ct -pretty 2> /dev/null 1> infrastructure/templates/userdata/ignition.json
	@echo "!!!!!!!!!!! RENDERED IGNITION FUZE !!!!!!!!!!!"

get-modules: 
	@cd infrastructure && terraform get -update
	@echo "!!!!!!!!!!! MODULES FETCHED !!!!!!!!!!!"

plan-infra: infrastructure/deployment.tf get-modules render-ignition-fuze infrastructure/templates/userdata/ignition.json
	@cd infrastructure && terraform plan -out infra.tfplan
	@echo "!!!!!!!!!!! INFRASTRUCTURE PLANNED !!!!!!!!!!!"

build-infra: plan-infra infrastructure/infra.tfplan
	@cd infrastructure && terraform apply infra.tfplan
	@echo "!!!!!!!!!!! INFRASTRUCTURE BUILT !!!!!!!!!!!"

clean-infra:
	@cd infrastructure && \
				 	terraform destroy --force && \
					rm -rf .terraform \
				 	infra.tfplan \
					terraform.tfstate \
					terraform.tfstate.backup
	@echo "!!!!!!!!!!! INFRASTRUCTURE CLEANED !!!!!!!!!!!"

clean-infra-templates:
	@rm -rf ./fuze
	@cd infrastructure/templates/userdata && \
					rm -f ignition.json \
						ignition.yaml \
						terraform.tfstate \
					  terraform.tfstate.backups
	@echo "!!!!!!!!!!! INFRASTRUCTURE TEMPLATES CLEANED !!!!!!!!!!!"

show-infra:
	@echo "!!!!!!!!!!! INFRASTRUCTURE STATUS !!!!!!!!!!!"
	@cd infrastructure && terraform show

.PHONY: get-modules clean-infra
