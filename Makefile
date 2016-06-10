
all: build
	echo
	echo
	echo "To upload to docker hub, use 'make upload'"
	echo

run: build
	docker rm dbpedia
	docker run     --name dbpedia val314159/docker-virtuoso run

shell: build
	docker rm dbpedia
	docker run -it --name dbpedia val314159/docker-virtuoso run

build: Dockerfile start.sh virtuoso_deb wait_ready README.md
	docker build -t val314159/docker-virtuoso .

upload: build
	docker push val314159/docker-virtuoso
