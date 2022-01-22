
###########  debian 更新镜像源  ############

# gpg 导入公钥，说明见: https://unix.stackexchange.com/questions/274053/whats-the-best-way-to-install-apt-packages-from-debian-stretch-on-raspbian-jess
RUN echo " " > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian jessie main" >> /etc/apt/sources.list  && \
    echo "deb http://mirrors.aliyun.com/debian jessie-updates main" >> /etc/apt/sources.list  && \ 
    gpg --keyserver keyserver.ubuntu.com --recv-key 7638D0442B90D010 && \
    gpg -a --export 7638D0442B90D010 | apt-key add - && \
    apt-get update 
    
# 不过在安装 curl 的时候，可能遇到 libcurl4 and libcurl3 的问题，参考 https://forum.vestacp.com/viewtopic.php?t=18201
############# debian 结束 #################
    
# apt install -y language-pack-zh-hans

# 开发环境可以不清理
# apt clean && apt autoclean && apt -y autoremove && \
# rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# lrzsz: window / linux 互传文件:

###########################################################
#                        C++                              #
###########################################################
# bazel
# 参考: https://docs.bazel.build/versions/master/install-ubuntu.html#install-with-installer-ubuntu
# buildifier 检查和格式化 WORKSPACE .bzl BUILD 文件
# 然后在setting.json中设置   
# "bazel.buildifierExecutable": "/usr/local/bin/buildifier-linux-amd64",
ADD cache/bazel-4.0.0-installer-linux-x86_64.sh /tmp
ADD cache/buildifier-linux-amd64 /usr/local/bin
RUN apt update && \
    apt-get install -y openjdk-11-jdk && \
    chmod +x /tmp/bazel-4.0.0-installer-linux-x86_64.sh && \
    bash /tmp/bazel-4.0.0-installer-linux-x86_64.sh && \
    chmod +x /usr/local/bin/buildifier-linux-amd64 && \
    apt clean && rm -rf /tmp/*