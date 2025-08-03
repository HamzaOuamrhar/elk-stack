all:
	docker compose up -d

down:
	docker compose down

e:
	docker exec -it --user root elasticsearch bash

k:
	docker exec -it --user root kibana bash

l:
	docker exec -it --user root logstash bash

b:
	docker compose up -d --build

clean: 
	docker compose down --rmi all --volumes --remove-orphans

super_clean: clean
	docker system prune -a

.PHONY: e
