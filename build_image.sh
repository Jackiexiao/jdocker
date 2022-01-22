#!/bin/bash
# 导入环境变量，后面可以换成 docker-compose
source .env

# sed -i "s/FROM.*/FROM ${base_build_image}/g" Dockerfile

###########################################################
#                         无需修改                          #
###########################################################
docker build \
    --build-arg GIT_USER_NAME=$git_user_name \
    --build-arg GIT_USER_EMAIL=$git_user_email \
    --build-arg ROOT_PASSWD=$root_passwd \
    -f $dockerfile_name \
    -t $docker_image_name .

echo "Successfully build docker images, name: $docker_image_name"
