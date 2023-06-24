FROM ubuntu:22.04 AS isolate_build
RUN apt-get update && apt-get install -y \
  libcap-dev git build-essential && rm -rf /var/lib/apt/lists/*
RUN git clone  -b v1.9 --single-branch https://github.com/ioi/isolate.git && cd isolate && make isolate && make install 


FROM tomcat:10.1
RUN apt-get update && apt-get install -y \
  libcap-dev && rm -rf /var/lib/apt/lists/*

RUN  mkdir -p /var/local/lib/isolate 
COPY --from=isolate_build /usr/local/etc/isolate /usr/local/etc/isolate
COPY --from=isolate_build /usr/local/bin/isolate-check-environment /usr/local/bin/isolate-check-environment
COPY --from=isolate_build /usr/local/bin/isolate /usr/local/bin/isolate

COPY target/javarunner.war /usr/local/tomcat/webapps/ROOT.war


