_GH_CLIENT_ID=${GH_CLIENT_ID}
_GH_CLIENT_SECRET=${GH_CLIENT_SECRET}

build-java:
	mvn clean package
build: build-java
	docker build -f docker/Dockerfile . -t nherbaut/javarunner
run:
	docker run -p 8081:8080 --rm --name javarunner -e GH_CLIENT_ID=$(_GH_CLIENT_ID) -e GH_CLIENT_SECRET=$(_GH_CLIENT_SECRET) nherbaut/javarunner
	
stop:
	docker rm -f $(docker ps -qa)
push:
	docker push nherbaut/javarunner

k-refresh:
	kubectl delete pods -l app=javarunner && sleep 5
k-logs:
	kubectl logs -l app=javarunner -f 
k: build push k-refresh k-logs
            
