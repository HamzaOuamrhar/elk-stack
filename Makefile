all:
	docker compose up -d

down:
	docker compose down

e:
	docker exec -it --user root elasticsearch bash

k:
	docker exec -it --user root kibana bash

b:
	docker compose up -d --build

bk:
	docker compose up -d --build kibana

clean: 
	docker compose down --rmi all --volumes --remove-orphans

.PHONY: e
