FROM ubuntu:18.04

# 安装界面无需交互
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /root
WORKDIR /root/
# ENV TZ=Asia/Shanghai # Centos

# 正常显示与输入中文，界面英文 locale to avoid issues with ASCII encoding
ENV LANG=C.UTF-8
# ENV LANG=en_US.UTF-8 # 会无法正确显示中文字符
# ENV LANG=zh_US.UTF-8 # 系统提示会改为中文，比如 apt install 的时候，看个人喜好改

# ubuntu 默认使用的是 [“/bin/sh”, “-c”]
SHELL [ "/bin/bash", "-c" ]

###########################################################
#                        基础设置                          #
###########################################################

# 修改时区 文件来源: /usr/share/zoneinfo/Asia/Shanghai 
ADD config/Shanghai /etc/localtime

RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y make gcc gdb g++ build-essential cmake && \
    apt-get install -y wget bash zip rsync less && \
    apt-get install -y -f git vim tree htop zsh tmux xclip curl iputils-ping

# apt install -y language-pack-zh-hans

# 开发环境可以不清理
# apt clean && apt autoclean && apt -y autoremove && \
# rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# lrzsz: window / linux 互传文件:

###########################################################
#                        C++                              #
###########################################################
# bazel
#### 在线安装: 需要科学上网 ####
# RUN true && \
#     apt install -y sudo apt-transport-https curl gnupg && \
#     curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg && \
#     mv bazel.gpg /etc/apt/trusted.gpg.d/ && \
#     echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list && \
#     apt update && apt install bazel

#### 离线安装 ####
# 参考: https://docs.bazel.build/versions/master/install-ubuntu.html#install-with-installer-ubuntu
ADD cache/bazel-4.0.0-installer-linux-x86_64.sh /tmp
ADD cache/buildifier-linux-amd64 /usr/local/bin
RUN apt update && \
    apt-get install -y openjdk-11-jdk && \
    chmod +x /tmp/bazel-4.0.0-installer-linux-x86_64.sh && \
    bash /tmp/bazel-4.0.0-installer-linux-x86_64.sh && \
    apt clean && rm -rf /tmp/*

# buildifier 检查和格式化 WORKSPACE .bzl BUILD 文件
ADD cache/buildifier-linux-amd64 /usr/local/bin
RUN chmod +x /usr/local/bin/buildifier-linux-amd64
# 然后在setting.json中设置   
# "bazel.buildifierExecutable": "/usr/local/bin/buildifier-linux-amd64",


###########################################################
#                     python+镜像                          #
###########################################################
ADD config/requirements.txt /tmp

# ln -sf : f, force，覆盖基础镜像中的设置
RUN apt-get update && \
    apt-get install -y python3-pip python3-dev && \
    cd /usr/local/bin && \
    ln -sf /usr/bin/python3 python && \
    ln -sf /usr/bin/pip3 pip 

# python 3.8
# RUN apt-get update && \
#     apt-get install --no-install-recommends -y python3.8 python3-pip python3.8-dev && \
#     ln -s /usr/bin/pip3 /usr/bin/pip  && \
#     ln -s /usr/bin/python3.8 /usr/bin/python

RUN python -m pip install --upgrade pip && \
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    pip install -U --no-cache-dir -r /tmp/requirements.txt && \
    rm -rf /tmp/*

###########################################################
#             tmux / zsh / htop / oh-my-zsh / fzf         #
###########################################################
ADD config/tmux.conf .tmux.conf
ADD config/zshrc .zshrc
ADD config/htoprc .config/htop/htoprc
# 配置oh-my-zsh
#### 在线安装 ####
# RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
#     chsh -s /bin/zsh && \
#     git clone https://github.com/zsh-users/zsh-completions /root/.oh-my-zsh/custom/plugins/zsh-completions && \
#     git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
#     git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    # git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    # ~/.fzf/install && \
#### 离线安装 ####
ADD cache/ohmyzsh-master.zip /tmp
ADD cache/zsh-completions-master.zip /tmp
ADD cache/zsh-autosuggestions-master.zip /tmp
ADD cache/zsh-syntax-highlighting-master.zip /tmp
ADD cache/fzf-master.zip /tmp
#  .fzf/install 中需要下载这个 对于 tar.gz 会自动解压缩...不再需要 unzip
ADD cache/fzf-0.26.0-linux_amd64.tar.gz /tmp

# unzip 指令 -o overwrite 不出现 "replace [yes] [no]"
# RUN git clone --depth 1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
# RUN git clone --depth 1 https://gitee.com/mirrors/oh-my-zsh ~/.oh-my-zsh && \
# cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
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
    ~/.fzf/install && \
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
ADD config/my_configs.vim /root/.vim_runtime/my_configs.vim

###########################################################
#                        git                              #
###########################################################
ARG GIT_USER_NAME
ARG GIT_USER_EMAIL
# core.quotepath false 解决中文乱码问题
RUN git config --global user.name ${GIT_USER_NAME} && \
    git config --global user.email ${GIT_USER_EMAIL} && \
    git config --global core.quotepath false && \
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

###########################################################
#                        ssh server                       #
###########################################################
# ssh 配置， 22 端口，用于vscode连接 
# 参考 https://github.com/rastasheep/ubuntu-sshd/blob/ed6fffcaf5a49eccdf821af31c1594e3c3061010/18.04/Dockerfile

ARG ROOT_PASSWD
ADD config/id_rsa /root/.ssh/id_rsa 
ADD config/id_rsa.pub /root/.ssh/id_rsa.pub
ADD config/authorized_keys /root/.ssh/authorized_keys
RUN apt update && \
    apt-get install -y openssh-server && \ 
    mkdir /var/run/sshd && \
    echo "root:${ROOT_PASSWD}" | chpasswd && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile && \
    echo "Host *" >> /root/.ssh/config && \
    echo "    StrictHostKeyChecking no" >> /root/.ssh/config && \
    echo "    GlobalKnownHostsFile  /dev/null" >> /root/.ssh/config && \
    echo "    UserKnownHostsFile    /dev/null" >> /root/.ssh/config && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 644 /root/.ssh/id_rsa.pub && \
    chmod 644 /root/.ssh/authorized_keys && \
    service ssh restart

EXPOSE 22 
# ENV NOTVISIBLE "in users profile"

###########################################################
#                        用户权限层                         #
###########################################################
# 创建一个与当前用户相同uid的、相同权限的docker用户，
# 但在docker容器中，其$HOME为/root 以便与root用户共享 zsh / fzf / vimrc 等等 的配置
# 在 sed 中，通过修改 / 为 | 作为 seperator 以解决 变量中有'/'转义字符的问题，来源:https://askubuntu.com/a/508174
# 参考: https://jtreminio.com/blog/running-docker-containers-as-current-host-user/
ARG USER
ARG UID
ARG FZF_SEARCH_DIR
ARG USER_PASSWD

RUN apt-get install -y sudo && \
    useradd -l -d /root -u ${UID} ${USER} && \
    echo "${USER}:${USER_PASSWD}" | chpasswd && \
    # 让root和USER共用HOME与配置（用户也可以复制一下，分开放配置文件）
    chown -R ${USER} /root && \
    usermod -a -G sudo ${USER} && \
    # sudo 免密码
    echo "${USER} ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && sudo chmod 440 /etc/sudoers.d/${USER} && \
    usermod -s /bin/zsh ${USER} && \
    sed -i "s|search_dir=\$HOME|search_dir=${FZF_SEARCH_DIR}|g" /root/.zshrc 
    
CMD ["/usr/sbin/sshd", "-D"]
# CMD ["zsh"]
