#!/bin/bash
source .env
# 删除旧docker  
# TODO 临时测试用
docker rm -f $container_name

###########################################################
#                    创建Docker容器                         #
###########################################################
# ! WARNING 这里挂载了 HOME 目录，如果不是你所期望的，请删除
docker run \
    -itd \
    --ipc=host \
    --privileged \
    --ulimit core=-1 \
    -p $ssh_host_port:$ssh_container_port \
    -p $extra_host_port:$extra_container_port \
    --restart=always \
    --name ${container_name} \
    $docker_image_name

# 配置含义
    # --ulimit core=-1 \ C++ 崩溃日志
    # -d daemon : 后台运行
    # --ipc=host : 与主机共享内存
    # --restart=always : docker意外重启时，容器也会重启
    # --runtime=nvidia \ 英伟达GPU 如果你用 tensorflow gpu 镜像的话
    # -v $HOME:$HOME \ 挂载本地目录，方便数据交互，不过更建议通过 git 管理代码

# 测试能否用SSH连接到容器
# `$ ssh root@[your_host_ip] -p {host_port}`

# 进入docker
# docker exec -it -u $USER $container_name zsh
docker exec -it $container_name zsh
