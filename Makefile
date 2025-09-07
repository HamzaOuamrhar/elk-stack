all:
	docker compose up -d

down:
	docker compose down

e:
	docker exec -it elasticsearch bash

k:
	docker exec -it kibana bash

l:
	docker exec -it logstash bash

user: 
	docker exec -it user bash

clean: 
	docker compose down --rmi all --volumes --remove-orphans
	for f in logs/*.log; do \
		echo "" > "$$f"; \
	done

super_clean: clean
	docker system prune -a

re: clean all

.PHONY: e user
