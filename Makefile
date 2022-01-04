.DEFAULT_GOAL := vidispine

docker:
	docker-compose up --build

vidispine: docker
