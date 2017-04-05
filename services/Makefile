# Services Makefile
#
build-images: build-image/demo-server build-image/demo-lb build-image/demo-bastion
	@echo "!!!!!!!!!!! IMAGES BUILT !!!!!!!!!!!"
  
build-image/%:
	@echo "********************************************************"
	@docker-compose build $*

pull-images: pull-image/demo-server pull-image/demo-lb pull-image/demo-bastion
	@echo "!!!!!!!!!!! IMAGES PUSHED !!!!!!!!!!!"

pull-image/%:
	@echo "********************************************************"
	@docker-compose pull $*

push-images: push-image/demo-server push-image/demo-lb push-image/demo-bastion
	@echo "!!!!!!!!!!! IMAGES PUSHED !!!!!!!!!!!"

push-image/%:
	@echo "********************************************************"
	@docker-compose push $*

run: build-images
	@docker-compose up $$args
	@echo "!!!!!!!!!!! CONTAINERS RUNNING !!!!!!!!!!!"

run-headless: build-images
	@docker-compose up -d $$args
	@echo "!!!!!!!!!!! CONTAINERS RUNNING !!!!!!!!!!!"

stop:
	@docker-compose down

clean-images: clean-image/demo-server clean-image/demo-lb clean-image/demo-bastion
	@echo "!!!!!!!!!!! IMAGES CLEANED !!!!!!!!!!!"

clean-image/%:
	@echo "********************************************************"
	@docker rmi ${REGISTRY}/$*

.PHONY: build-images clean-images
