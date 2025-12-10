all: build up

create_volumes:
	@mkdir -p /home/${USER}/data/mariadb
	@mkdir -p /home/${USER}/data/wordpress
	

build: create_volumes
	@cd srcs && docker compose build
	
up:
	@cd srcs && docker compose up -d

down:
	@cd srcs && docker compose down

fclean:
	@cd srcs && docker compose down -v
	@yes | docker system prune -af
	@yes | docker volume prune -f
	@yes | docker network prune -f
	@sudo rm -rf /home/${USER}/data/mariadb
	@sudo rm -rf /home/${USER}/data/wordpress

clean: down

re: clean all

restart:
	@cd srcs && docker compose restart

.PHONY: all create_volumes build up down fclean clean re restart\

