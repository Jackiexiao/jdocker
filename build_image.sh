###########################################################
#                    Docker开发环境配置区域                  #
###########################################################
# 基础镜像 Basic Image

# base_image="pytorch/pytorch:1.8.0-cuda11.1-cudnn8-devel"
# base_image="tensorflow/tensorflow:nightly-gpu-jupyter"
# base_image=ufoym/deepo:pytorch-py36-cpu
base_image="ubuntu:18.04"

sed -i "s|FROM.*|FROM ${base_image}|g" Dockerfile

# docker 镜像名称与版本号
docker_image_name=jdocker
version="ubuntu_18.04"

# ssh key 使用与宿主机相同的配置
cp ~/.ssh/id_rsa config/id_rsa
cp ~/.ssh/id_rsa.pub config/id_rsa.pub
cp ~/.ssh/authorized_keys config/authorized_keys

# Git
git_user_name=your_name
git_user_email=your_email

# 设置root和用户及其密码
root_passwd=docker
user_passwd=docker
user=$USER
uid=`id -u $USER`

# fzf 插件中 Alt+C / Ctrl+T 搜索的根目录
fzf_search_dir=$HOME

# 其他配置文件在 config 下，需要自行配置，尤其是 python 的 requirements

###########################################################
#                         无需修改                          #
###########################################################
docker build \
    --build-arg GIT_USER_NAME=$git_user_name \
    --build-arg GIT_USER_EMAIL=$git_user_email \
    --build-arg FZF_SEARCH_DIR=$fzf_search_dir \
    --build-arg UID=$uid \
    --build-arg USER=$user \
    --build-arg ROOT_PASSWD=$root_passwd \
    --build-arg USER_PASSWD=$user_passwd \
    -t $docker_image_name:$version .
