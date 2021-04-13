###########################################################
#                    配置Docker容器                         #
###########################################################
container_name=jdocker-daemon
image_name=jdocker
version="ubuntu_18.04"

# ssh 端口
host_port=8028
container_port=22

# jupyter notebook 端口
jupyter_host_port=8100
jupyter_container_port=8888

# 删除旧docker
docker rm -f $container_name

###########################################################
#                    创建Docker容器                         #
###########################################################
docker run \
    -itd \
    --runtime=nvidia \
    --ipc=host \
    -v $HOME:$HOME \
    -p $host_port:$container_port \
    -p $jupyter_host_port:$jupyter_container_port \
    --restart=always \
    --name ${container_name} \
    $image_name:$version
    
# 配置含义
    # -d daemon : 后台运行
    # --ipc=host : 与主机共享内存
    # --restart=always : docker意外重启时，容器也会重启

# 服务器中测试 docker
    # `$ docker port [your_container_name] {container_port}`
    # 输出: # 0.0.0.0:{host_port}
    # 最后测试能否用SSH连接到远程docker：
    # `$ ssh root@[your_host_ip] -p {host_port}`

# 进入docker
docker exec -it -u $USER $container_name zsh
# 或者通过 ssh / vscode 连接
# ssh $USER@host_ip -p $host_port
