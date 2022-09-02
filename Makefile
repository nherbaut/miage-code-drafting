_GH_CLIENT_ID=${GH_CLIENT_ID}
_GH_CLIENT_SECRET=${GH_CLIENT_SECRET}

build-java:
	mvn clean package
build: build-java
	docker build -f docker/Dockerfile . -t nherbaut/javarunner
run:
	docker run --privileged -p 8080:8080 --rm --name javarunner -e GH_CLIENT_ID=$(_GH_CLIENT_ID) -e GH_CLIENT_SECRET=$(_GH_CLIENT_SECRET) nherbaut/javarunner
	
stop:
	docker rm -f $(docker ps -qa)
push:
	docker push nherbaut/javarunner
            
