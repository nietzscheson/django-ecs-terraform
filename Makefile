.PHONY: init

init:
	make down
	make up
	make ps
	# make fixtures
down:
	docker-compose down --volumes --remove-orphans
pull:
	docker-compose pull
build:
	docker-compose build
up:
	make pull
	make build
	docker-compose up -d
ps:
	docker-compose ps
migrations:
	docker-compose run --rm core python manage.py makemigrations
migrate:
	make migrations
	docker-compose run --rm core python manage.py migrate
fixtures:
	make migrate
su:
	docker-compose run --rm core python manage.py createsuperuser
test:
	docker-compose run --rm core python manage.py test
debug:
	docker-compose -f docker-compose.yaml -f docker-compose.debug.yaml up --build -d
remove_files:
	rm -rf core/media/*
prune:
	@make remove_files
	make down
	docker volume prune -f
	docker system prune -f
collecstatic:
	docker-compose run --rm core python manage.py collectstatic --noinput
shell:
	docker-compose exec core python manage.py shell
terraform.init:
	terraform -chdir=terraform init
terraform.validate: terraform.init
	terraform -chdir=terraform validate
terraform.plan: terraform.validate
	terraform -chdir=terraform plan
terraform.apply: terraform.plan
	terraform -chdir=terraform apply -auto-approve
terraform.destroy: terraform.plan
	terraform -chdir=terraform destroy
ecr.login:
	aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 299264538740.dkr.ecr.us-west-1.amazonaws.com
ecs.deploy:
	docker compose -f stack.yaml up -d