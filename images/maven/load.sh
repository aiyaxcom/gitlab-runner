docker save -o maven-git.tar maven-git:latest
docker cp maven-git.tar dind:/
docker exec -it dind docker load --input maven-git.tar
