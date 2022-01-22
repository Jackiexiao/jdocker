FROM tensorflow/tensorflow:latest-devel-gpu
# FROM ufoym/deepo:pytorch-py36-cpu
# FROM pytorch/pytorch:1.8.0-cuda11.1-cudnn8-devel

# 安装界面无需交互
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /root
WORKDIR /root/
# ENV TZ=Asia/Shanghai # Centos

# 正常显示与输入中文
ENV LANG=C.UTF-8
SHELL [ "/bin/bash", "-c" ]

###########################################################
#                        基础设置                          #
###########################################################

# 修改时区 文件来源: /usr/share/zoneinfo/Asia/Shanghai 
ADD etc/Shanghai /etc/localtime

RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y make gcc gdb g++ build-essential cmake && \
    apt-get install -y wget bash zip rsync less && \
    apt-get install -y -f git vim tree htop zsh tmux xclip curl iputils-ping

# apt install -y language-pack-zh-hans

# 开发环境可以不清理
# apt clean && apt autoclean && apt -y autoremove && \
# rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

###########################################################
#             tmux / zsh / htop / oh-my-zsh / fzf         #
###########################################################
ADD etc/tmux.conf .tmux.conf
ADD etc/zshrc .zshrc
ADD etc/htoprc .config/htop/htoprc
ADD etc/fd_ignore .config/fd/ignore
# 配置oh-my-zsh
ADD cache/ohmyzsh-master.zip /tmp
ADD cache/zsh-completions-master.zip /tmp
ADD cache/zsh-autosuggestions-master.zip /tmp
ADD cache/zsh-syntax-highlighting-master.zip /tmp
ADD cache/fzf-master.zip /tmp
ADD cache/fzf-0.26.0-linux_amd64.tar.gz /tmp
ADD cache/fd-musl_8.2.1_amd64.deb /tmp

RUN unzip -o /tmp/ohmyzsh-master.zip && \
    mv ohmyzsh-master /root/.oh-my-zsh/ && \
    chsh -s /bin/zsh && \
    unzip -o /tmp/zsh-completions-master.zip  && \
    mv zsh-completions-master /root/.oh-my-zsh/custom/plugins/zsh-completions && \
    unzip -o /tmp/zsh-autosuggestions-master.zip && \
    mv zsh-autosuggestions-master /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    unzip -o /tmp/zsh-syntax-highlighting-master.zip && \
    mv zsh-syntax-highlighting-master /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    unzip -o  /tmp/fzf-master.zip && \
    mv fzf-master ~/.fzf && \
    mv /tmp/fzf ~/.fzf/bin && \
    chmod +x ~/.fzf/bin/fzf && \
    ~/.fzf/install --all && \
    dpkg -i /tmp/fd-musl_8.2.1_amd64.deb && \
    rm -rf /tmp/*

###########################################################
#                         vimrc                           #
###########################################################
# 两种配置供选择
# 1. 简单的vim，无插件
# ADD config/simple_vimrc .vimrc
# 使用 https://github.com/amix/vimrc.git
# 2. 好用的 vim 配置 amix/vimrc
# 中文教程: https://www.jianshu.com/p/352a132a1bfa
# 安装 2 会覆盖 1 中的vimrc
ADD cache/vimrc-master.zip /tmp
RUN tree && \
    # git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime && \
    # sh ~/.vim_runtime/install_awesome_vimrc.sh
    unzip -o /tmp/vimrc-master.zip && \
    mv vimrc-master ~/.vim_runtime && \
    sh ~/.vim_runtime/install_awesome_vimrc.sh && \
    rm -rf /tmp/*
# 覆盖默认配置 
ADD etc/my_configs.vim /root/.vim_runtime/my_configs.vim

###########################################################
#                        git                              #
###########################################################
ARG GIT_USER_NAME
ARG GIT_USER_EMAIL
ADD etc/gitignore .gitignore
# core.quotepath false 解决中文乱码问题
RUN git config --global user.name ${GIT_USER_NAME} && \
    git config --global user.email ${GIT_USER_EMAIL} && \
    git config --global core.quotepath false && \
    git config --global core.excludesfile ~/.gitignore && \
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

###########################################################
#                        ssh server                       #
###########################################################
# ssh 配置， 22 端口，用于vscode连接 
# 参考 https://github.com/rastasheep/ubuntu-sshd/blob/ed6fffcaf5a49eccdf821af31c1594e3c3061010/18.04/Dockerfile

ARG ROOT_PASSWD
RUN apt update && \
    apt-get install -y openssh-server && \ 
    mkdir /var/run/sshd && \
    echo "root:${ROOT_PASSWD}" | chpasswd && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    mkdir .ssh && \
    echo "export VISIBLE=now" >> /etc/profile && \
    echo "Host *" >> /root/.ssh/config && \
    echo "    StrictHostKeyChecking no" >> /root/.ssh/config && \
    echo "    GlobalKnownHostsFile  /dev/null" >> /root/.ssh/config && \
    echo "    UserKnownHostsFile    /dev/null" >> /root/.ssh/config && \
    service ssh restart

EXPOSE 22 
CMD ["/usr/sbin/sshd", "-D"]
# CMD ["zsh"]
