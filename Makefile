JENKINS_VERSION=2.399

build:
	docker build --build-arg JENKINS_VERSION=${JENKINS_VERSION} -t afdaniele/jenkins:${JENKINS_VERSION} -t afdaniele/jenkins:latest ./

push:
	docker push afdaniele/jenkins:${JENKINS_VERSION}
	docker push afdaniele/jenkins:latest
