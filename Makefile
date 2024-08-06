

#linux
WP_DATA = /home/pfalasch/data/wordpress
DB_DATA = /home/pfalasch/data/mariadb

all: up


setup:
	@if ! grep -q "127.0.0.1 pfalasch.42.fr" /etc/hosts; then \
		echo "127.0.0.1 pfalasch.42.fr" | sudo tee -a /etc/hosts; \
	fi

up: create_dirs setup build
	docker-compose -f ./srcs/docker-compose.yml up -d

create_dirs:
	@mkdir -p $(WP_DATA) $(DB_DATA)

down:
	docker-compose -f ./srcs/docker-compose.yml down

stop:
	docker-compose -f ./srcs/docker-compose.yml stop

start:
	docker-compose -f ./srcs/docker-compose.yml start

build:
	@clear
	docker-compose -f ./srcs/docker-compose.yml build

clean:
	@docker stop $$(docker ps -qa) || true
	@docker rm $$(docker ps -qa) || true
	@docker rmi -f $$(docker images -qa) || true
	@docker volume rm $$(docker volume ls -q) || true
	@docker network rm $$(docker network ls -q) || true
	@rm -rf $(WP_DATA) $(DB_DATA) || true
	@docker system prune -a --volumes -f || true

re: clean up

.PHONY: all up down stop start build clean re create_dirs