
all: build
	echo
	echo
	echo "To upload to docker hub, use 'make upload'"
	echo

build: Dockerfile start.sh virtuoso_deb wait_ready
	docker build -t val314159/docker-virtuoso .

upload: build
	docker push val314159/docker-virtuoso
