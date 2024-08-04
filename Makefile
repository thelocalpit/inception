WP_DATA = /home/pfalasch/data/wordpress
DB_DATA = /home/pfalasch/data/mariadb

all: up


setup:
	@if ! grep -q "127.0.0.1 pfalasch.42.fr" /etc/hosts; then \
		echo "127.0.0.1 pfalasch.42.fr" | sudo tee -a /etc/hosts; \
	fi

# Target per avviare i servizi
up: create_dirs setup build
	docker-compose -f ./srcs/docker-compose.yml up -d

# Target per creare le directory
create_dirs:
	@mkdir -p $(WP_DATA) $(DB_DATA)

# Target per fermare i servizi e rimuovere i container e le reti
down:
	docker-compose -f ./srcs/docker-compose.yml down

# Target per fermare i servizi senza rimuoverli
stop:
	docker-compose -f ./srcs/docker-compose.yml stop

# Target per avviare i servizi
start:
	docker-compose -f ./srcs/docker-compose.yml start

# Target per costruire le immagini
build:
	@clear
	docker-compose -f ./srcs/docker-compose.yml build

# Target per pulire l'ambiente Docker
clean:
	@docker stop $$(docker ps -qa) || true
	@docker rm $$(docker ps -qa) || true
	@docker rmi -f $$(docker images -qa) || true
	@docker volume rm $$(docker volume ls -q) || true
	@docker network rm $$(docker network ls -q) || true
	@rm -rf $(WP_DATA) $(DB_DATA) || true

prune: clean
	@docker system prune -a --volumes -f

# Target per ricostruire e avviare
re: clean up

# Dichiarazione dei target come phony
.PHONY: all up down stop start build clean re create_dirs


# docker ps: Questo comando mostra i container Docker attualmente in esecuzione. Di default, visualizza solo i container attivi.
# docker pull <immagine>: Scarica un'immagine dal registro Docker
# docker images: Elenca tutte le immagini Docker locali
# docker rmi <immagine>: Rimuove un'immagine Docker

# Gestione dei Container
# docker run <immagine>: Crea e avvia un nuovo container
# docker ps: Elenca tutti i container in esecuzione
# docker ps -a: Elenca tutti i container, inclusi quelli non in esecuzione
# docker start <container>: Avvia un container esistente
# docker stop <container>: Ferma un container in esecuzione
# docker restart <container>: Riavvia un container
# docker rm <container>: Rimuove un container
# docker logs <container>: Visualizza i log di un container
# docker exec -it <container> <comando>: Esegue un comando all'interno di un container in esecuzione

# Gestione delle Reti
# docker network create <rete>: Crea una rete Docker
# docker network ls: Elenca tutte le reti Docker
# docker network inspect <rete>: Visualizza i dettagli di una rete
# docker network connect <rete> <container>: Connette un container a una rete
# docker network disconnect <rete> <container>: Disconnette un container da una rete

# Gestione dei Volumi
# docker volume create <volume>: Crea un volume Docker
# docker volume ls: Elenca tutti i volumi Docker
# docker volume inspect <volume>: Visualizza i dettagli di un volume
# docker run -v <volume>:<percorso_container> <immagine>: Crea un container con un volume montato
# docker volume rm <volume>: Rimuove un volume

# Gestione dei Registry
# docker login: Effettua il login a un registro Docker
# docker push <immagine>: Carica un'immagine su un registro Docker
# docker search <immagine>: Cerca un'immagine su Docker Hub
