
# TODO
- [ ] 复用基础配置，比如vim/fzf/zsh 基础配置
- [ ] 做几个基础镜像，用户在上面修改配置就行，不需要重新构建的方法
- [ ] vscode 连接的时候，终端默认用 zsh 

待测试的镜像
ubuntu18.04-cpp-bazel.Dockerfile
tensorflow 的镜像

# 开发日志
2022-1-14: 
1. 遇到一些版本升级的问题... 比如 fzf 的 bin 版本不对应，然后在安装时，就还需要科学上网...
2. 由于安装了很多依赖，以及网络问题，构建镜像耗时很久..

# 个人
自己的常用的 requirements 放在了 reference 文件夹里头
# 发布前
- [ ] 记得提交 env 的模板
- [ ] run_container 中删除危险的 delete容器操作
- [ ] 多阶段构建，减小镜像的体积
    "尝试分阶段构建，但是只能省个100M，可能miniconda很占内存?"
    此外，自己没有删除更新的部分，apt install 也占了很多。。
- [ ] fzf 那里还是有网络问题...（算了，不解决了... 用户自己搞定把，这个事情再多花点时间就不值得了..）没准到最后就自己在用..
# TODO
- [x] 补充一个 fd 教学
- [x] fd 代替 fzf 中的搜索功能，以便能利用 .gitignore 排除某些文件，见: https://github.com/junegunn/fzf#respecting-gitignore 

If we work in a directory that is a Git repository (or includes Git repositories), fd does not search folders (and does not show files) that match one of the .gitignore patterns

By default, fd does not search hidden directories and does not show hidden files in the search results. To disable this behavior, we can use the -H (or --hidden) option:

To really search all files and directories, simply combine the hidden and ignore features to show everything (-HI).

  - [ ] 目前更加建议使用 更改 `search_dir` 的方法
- [x] 用 env 还是 config.sh
  - [x] env ，让用户自己拷贝成 .env，而且 docker-compose 文件可以用
  - [ ] 用 config.sh，这样可以跑 拷贝 .ssh 的操作，不过似乎不太好...
- [ ] 自动构建镜像并发布到 hub 上（不过 git 是隐私部分..)
- [x] 支持 poetry
- [x] 支持 miniconda
- [x] 全局 gitignore
- [ ] docker-compose.yml 代替 run_container.sh
- [ ] docker + compose 安装教程（也方便自己查看..）
- [ ] ubuntu 18.04 的基础镜像会不会不太好? 比如缺失一些内容?
- [ ] 问题: zshrc 与 poetry 中的内容耦合了... 最好是 一开始就拷贝 zshrc 后面每安装一个新的内容，就export 进去
- [ ] 没有控制版本，每次都拉取最新的，可能会导致有问题

## 如何共享所有用户的配置，支持以本地用户进入
总的来说，相当麻烦...除非你事先就创建了这个user..

- [ ] 支持用户权限，且支持 sudo
  - 类似 tensorflow docker，使用新用户，但仍能使用相同的终端配置
  - `$ docker run -u $(id -u):$(id -g) args...`
  - docker 中创建了跟宿主机用户相同权限和名称的账户
  - 该账户在 docker 内有 sudo 权限，免密码
  - 该账户与 root 共享 HOME 目录，以及上述的 zsh 等配置
  - tensorflow 是如何配置得到这样的一个默认目录和默认终端的..
  - 见: https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/ci_build/Dockerfile.gpu
  - 参考: https://faun.pub/set-current-host-user-for-docker-container-4e521cef9ffc

### 如何 在所有用户中 share zsh 的配置
1. 简易的方法（我建议用户在
```
sudo chmod 744 /root/.zshrc
ln -s $HOME/.zshrc   /root/.zshrc
ln -s $HOME/.oh-my-zsh   /root/.oh-my-zsh
chsh -s $(which zsh) $(whoami)
```
参考: https://askubuntu.com/a/1303633

2. 复杂的方法（真正在所有用户上通用） https://stackoverflow.com/questions/31624649/how-can-i-get-a-secure-system-wide-oh-my-zsh-configuration

# 常用启动脚本
su $username -c "jupyter notebook --no-browser --ip=0.0.0.0 --port 6050 --allow-root --notebook-dir='/data1/xiaojianjin/zhuiyi/' --NotebookApp.token="" —allow-root"


# 历史

解决方法:  base image 中 带斜线 和 冒号，两次替换即可
# base_image=ufoym/deepo:pytorch-py36-cpu
version=${base_image/:/_}
version=${version/\//-}


['', '/usr/lib/python36.zip', '/usr/lib/python3.6', '/usr/lib/python3.6/lib-dynload', '/root/.local/lib/python3.6/site-packages', '/data1/xiaojianjin/zhuiyi/zyfrontend/pyFrontend', '/usr/local/lib/python3.6/dist-packages', '/usr/lib/python3/dist-packages']
# 参考写法

FROM registry01.wezhuiyi.com/library/alpine:3.10

RUN wget -O - --header "${TTS_URL_HEADER}" "${TTS_FRONT_MODEL_URL}/6.0.0/yitts_frontend_model.tar.gz" \
        | tar -zxv && ln -s yitts_frontend_model  yitts_frontend_model \

ENV LANG=en_US.UTF-8
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
# todo
- [ ] 似乎经常性会出现前面说到的 ssh 连接问题，重新构建镜像之后就会吗?
- [ ] 改成 start.sh ?

优先级高
- [ ] 在dockerfile指定安装 vscode-server 以及 extension
    - 相关讨论: https://github.com/microsoft/vscode-remote-release/issues/1718
    - 当前/临时解决方案: vscode 第一次连接容器后自动下载 server 端，安装好插件后，始终维持这个容器
    - 我以为我找到了对应的[dockerfile](https://github.com/cmiles74/docker-vscode/blob/935b7f3ca6e5a7a53b4528f665ed508ccd4c3a1b/Dockerfile#L31)，然而这玩意是vscode客户端
    
优先级中
- [ ] docker 容器中好像没办法退出回到 宿主机中? hmmm 可以的，ssh连接回宿主机，牛逼
- [ ] 减少镜像体积

在每一个 apt-get update 后都使用 ?

    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*


优先级低
- [ ] 分享到 github 中
- [ ] 顺带内置一个 https://github.com/cdr/code-server ?
- [ ] 将vscode server安装的步骤都整合到 Dockerfile 里头，参考 https://github.com/cmiles74/docker-vscode/blob/master/Dockerfile
- [ ] 生产环境是 centos ，开发环境是 ubuntu .... Dockerfile 都难搞...
- [ ] docker compose ，不过目前感觉没有这个必要
- [ ] 现在很少用 jupyter notebook 了，vscode 自带的 notebook 就挺好用，感觉不需要 加启动一个 Jupyter notebook 以及 notebook 的插件.... 干啥啥不行，折腾环境第一名2333

老实讲我不是太理解 vscode 自带的这个插件
https://code.visualstudio.com/docs/remote/containers

简化了创建Dockerfile的过程? 把安装 ssh client 隐去了?

将 docker run 的过程简化成了 .devcontainer/devcontainer.json 吗?
https://code.visualstudio.com/docs/remote/containers


### vscode插件问题
你可以把安装好插件的容器存起来
通过这个指令获得所有linux已安装的插件，并且放到 shell 脚本中执行
code --list-extensions | xargs -L 1 echo code --install-extension

或者window 的list
code --list-extensions | % { "code --install-extension $_" }

# 历史
### 有意思的项目
通过网页访问 docker 
https://github.com/cdr/code-server
把上面的服务封装到docker里头
https://github.com/dclong/docker-vscode-server
可以直接拿的镜像
https://hub.docker.com/r/codercom/code-server

## 使用 docker compose
    * TODO
        * 提供 守护进程 （用于 tensorboard 或者 jupyter notebook）
        * 提供 终端执行版本
    * docker-compose up -d
## 改造后使用
* 通过 修改 dockerfile，例如复制片段，或者修改 docker From 设置
* 构建镜像后，通过容器搭建新环境，然后save为镜像使用

# 构建
第一步，先下载所有依赖，第三方包到本地文件夹，避免后续的构建出现网络问题
第二步，构建
```
docker build -t jdev:0.1 .
```

也许后面比较好的构建方式是，到一个"网络良好"能"科学上网"的机器上构建一个基础镜像，日后在这个镜像上修改...
要不然就像我这样，一个个下载搞了
