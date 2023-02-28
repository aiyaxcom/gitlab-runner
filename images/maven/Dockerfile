FROM maven:3.8.1-ibmjava-8
MAINTAINER Jason Wang <jaswan@foxmail.com>
RUN apt update && apt install -y git
ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
