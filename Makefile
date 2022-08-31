build:
	mvn clean package
	docker build -f docker/Dockerfile . -t nherbaut/javarunner

run:
	docker run -p 8080:8080 --rm --name javarunner nherbaut/javarunner
stop:
	docker rm -f $(docker ps -qa)
push:
	docker push nherbaut/javarunner
