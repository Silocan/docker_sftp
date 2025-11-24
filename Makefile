.PHONY: build up down restart logs shell test

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f

shell:
	docker-compose exec sftp sh

test:
	@echo "Test de connexion SFTP..."
	@echo "sftp -P 2222 sftpuser@localhost"
	@echo "Mot de passe: sftpuser"

