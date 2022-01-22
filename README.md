# 好用的 Docker 开发环境

- 开发环境，一次构建，多处使用
- 可 vscode 远程连接(remote)
- 配置 vim/oh-my-zsh/fzf/python/C++
- 可基于 ubuntu 的基础镜像构建(如 tensorflow/pytorch)开发环境

# 为什么使用 docker 作为开发环境

- 某些场景下搭建开发环境很耗时，有 docker 能够显著减少配置环境所花费的时间，例如当你
  - tensorflow/pytorch 不使用 docker 需要自己配置 cuda，步骤繁琐
  - 拥有多个开发服务器和需要不同开发环境的项目
  - 开发环境配置复杂，而且希望他人能够复用
  - 换了工作，电脑，需要重新配置
  - ...
- 你希望能复用其他人的 linux 开发环境，免于重新配置之苦

## 特性

- vscode
  - 配置 openssh，可以通过 vscode 连接 docker 远程开发
- 好用的开发配置
  - oh-my-zsh 与插件
  - [fzf](https://github.com/junegunn/fzf.git) 模糊搜索和跳转文件夹
  - [vimrc](https://github.com/amix/vimrc.git)
  - tmux htop
  - git 配置
- 基本的初始化
  - 中文时区 + 中文编码
  - 基础包 如 curl git vim
- 构建镜像前先下载相应的安装包，避免构建时可能的网络问题
- 支持的镜像
  - ubuntu18.04-python3.8.Dockerfile
    - poetry & pip 镜像
  - 其余的Dockerfile未测试

## 使用

简而言之，选择一个基于 ubuntu 系统的基础镜像，然后通过 Dockerfile 构建开发环境的镜像，最后通过 vscode 连接容器进行开发

### 最佳实践
1. 不推荐挂载本地目录，因为这样不方便共享 docker 开发容器，建议将项目通过 git 下载代码
2. 一个项目一个开发环境就够了，一个项目不要同时开发多个环境

### 构建镜像

- 前提: linux 服务器，安装有 docker

#### 通用镜像

- 首先下载相关的库，避免之后构建镜像时遇到网络问题 or 重复下载
  - `./download-zh.sh` 中国网络环境特供版...(换了镜像)
  - `./download.sh` 正常下载版
- 修改配置 `cp env .env` 拷贝文件后在`.env`中修改自己的设置，
- 查看 `Dockerfile`, 删除不需要的配置，例如基础镜像中已经有 python，可以删掉 python 部分
- `./build_image.sh`构建镜像
- `./run_container.sh`根据镜像创建一个开发容器


#### 个人镜像

用户可选择跳过下面的步骤，下面主要是做一些特殊操作，并且 commit 为新的镜像，使其成为一个"开箱即用"的个人开发镜像

1. 添加 ssh key 到 container，以便复用宿主机的 ssh 配置，大致操作如下

```
cp your_home/.ssh/id_rsa /root/.ssh/id_rsa
cp your_home/.ssh/id_rsa.pub /root/.ssh/id_rsa.pub
cp your_home/.ssh/authorized_keys /root/.ssh/authorized_keys
chmod 600 /root/.ssh/id_rsa
chmod 644 /root/.ssh/id_rsa.pub
chmod 644 /root/.ssh/authorized_keys
```

2. vscode 远程连接容器

- 安装 vscode remote 插件，
- 在 C:\Users\username\.ssh\config 文件中 参照如下格式修改，方便后面连接这个开发容器
  ```
  Host hostname
    HostName your_remote_server_ip
    User $user
    Port $host_port
  ```
- 连接上容器后，我们来配置一下，主要是在 container 中下载 vscode 服务端+插件
  - 安装插件: 可以手动在 extension 页面中点击远程安装，也可以`ctrl+shift+P`输入`install local extensions in` remote 来一次性安装所有插件。
  - 修改配置
    - 例如 python 项目 .vscode/setting.json 中，修改 `python.pythonPath`为 docker 中的`/usr/bin/python3`

3. [optional]通过 docker commit 来保存容器为镜像

- 可以将配置好 vscode 的容器通过 `docker commit [container_id] [image_name]`再存为一个镜像，避免后续重复配置 vscode，PS: vscode 远程无法通过脚本安装，[原因](https://code.visualstudio.com/docs/remote/faq#_can-vs-code-server-be-installed-or-used-on-its-own)

## 使用技巧

有时间的话，建议到相应的 github 仓库去看使用说明，下面仅介绍简要的功能

### fzf

来源: https://github.com/junegunn/fzf#key-bindings-for-command-line

`Alt+C` 快速跳转文件夹是我最喜欢的功能，不过你需要在 vscode 中通过`ctrl k + ctrl s`打开快捷键设置，将冲突的快捷键（默认是 toggle 搜索的大小写敏感）删除，就可以在终端中使用这个快捷键了

- `alt+c` 模糊搜索 HOME 下文件夹，实现快速跳转
- `ctrl+t` 模糊搜索 HOME 下文件，快速得到文件路径，在 vscode 终端下，我经常使用 `code -r ctrl+T` 的方式来快速访问文件
- `vi **[tab]` 模糊搜索当前路径下的文件，并用 vim 打开
- `cd **[tab]` 模糊搜索当前路径下的文件夹，并跳转

ps

- 如果想要改变`alt+c`的默认搜索路径，可以修改 `~/.zshrc` 下的 `search_dir`，默认是在 `$HOME` 里头搜索
- 此 docker 中 fzf 使用的是 fd 模糊搜索，见[fd 教程](https://github.com/sharkdp/fd#how-to-use)
  - 搜索默认会忽略 `.`开头的隐藏文件，如果是在 git 仓库里，则会忽略`.gitignore`中的文件
  - 如果搜索的时候想要忽略特定的文件夹，请修改`~/.config/fd/ignore`文件，其语法类似`.gitignore`

### oh my zsh

来源: https://github.com/ohmyzsh/ohmyzsh

- 安装了自动补全，高亮等插件
- alias 命令别名
  - `gst` git stats
  - `gco` git checkout
  - `gcmsg` git commit -m
  - ...还有一大堆...
  - 请阅读: https://github.com/ohmyzsh/ohmyzsh/wiki/Cheatsheet

### vimrc

来源: https://github.com/amix/vimrc

如果期望有自动补全，还可以参考 scripts 下安装 YouCompleteMe

cheat-sheet

0. 翻页
   `ctrl d` 向下翻半页，注意 **ctrl f** 被绑定为搜索了，所以无法使用 ctrl f 翻页
   `ctrl u` 向上翻半页
1. 全局查找文件(ctrlp 插件)  
   `ctrl + f` --打开全局文件搜索面板  
   `Esc` --退出全局文件搜索面板
2. tab(标签)相关  
   `gt` --后一个标签  
   `gT` --前一个标签  
   `num` + gt --跳转至第 num 个标签  
   `,tl` --上一次的标签  
   `:q` --关闭标签  
   `:Te` --新建标签，并打开当前文件目录  
   `,tn` --新建空白标签
3. 目录树(NERD_tree 插件)  
   `,nn` --打开目录树  
   `,nn` --关闭目录树
4. 窗口相关  
   `ctrl + w + q` --关闭窗口  
   `:q` --关闭窗口，窗口只有一个 tab 的情况  
   `ctrl + w + w` --切换窗口  
   `:sp` --竖直方向上拆分当前窗口  
   `:vsp` --水平方向上拆分当前窗口
5. 如何打开一个工程  
   在某个工程的根目录下输入打开 vim，则该 vim 窗口的文件操作默认为整个工程，比如全局搜索文件或字段
6. 全局搜索字段(ack 插件)  
   `,g` --打开全局字段搜索面板，默认大小写敏感，-i 不区分大小写，-w 全词匹配  
   `q` --退出全局字段搜索面板
7. 当前文件所在的目录  
   `:E` --打开当前目录，一般用于切换当前目录的文件  
   `:Te` --新建标签并打开当前目录，一般用于打开当前目录下的其它文件
8. 查看最近打开的文件列表  
   `,f` --打开面板  
   `q` --退出面板
9. 当前文件下搜索  
   `*`\--按下即可搜索光标所在的单词或当前选中的内容，不区分大小写  
   `gd` --光标移动至单词，按下即可搜索该单词，区分大小写  
   `/` --输入单词向下搜索  
   `?` --输入单词向上搜索，一般用于查 log，配合 G 跳转至文件底部使
10. 显示行修改标志  
    `,d` --显示与不显示逐一切换
11. 光标停留的位置记录  
    `ctrl + o` --上一个时间点光标停留的位置  
    `ctrl + i` --下一个时间点光标停留的位置
12. 文件刷新，即重新载入  
    `:e` --重新载入  
    `:e!` --放弃当前修改，强制重新载入  
    `:e file_dir` --载入 file_dir 路径下的某个文件
13. 粘贴 0 号寄存器的内容  
    `ctrl + r + 0` --比如 y 复制选中的内容后粘贴到命令输入框
14. 折叠命令  
    `za` --打开或关闭当前折叠  
    `zM` --关闭所有折叠  
    `zR` --打开所有折叠
15. 跳出双引号继续编辑  
    有些时候输入完字符串需要移动光标至双引号外继续输入  
    `"` --在 " 处输入 " ，即可将光标跳转至当前双引号之外
16. 文件路径  
    `:f` --查看当前文件路径
17. 变量名补全  
    `ctrl + n` --自动补全变量名，再次输入匹配下一个
18. 代码块补全，只需输入部分代码，然后按 tab 键  
    lua 为例：  
    `if + tab` --if 代码块  
    `forp + tab` --for i,v in pairs() do end 代码块  
    `fori + tab` --for i,v in ipairs() do end 代码块  
    `fun + tab` --函数模板代码块
19. 代码检错  
    `:ALEToggle` --启动检错
20. 代码注释  
    `gcc` --注释当前行，再次输入则撤销注释  
    `num + gcc` --注释 num 行  
    `gc` --注释选中部分

## FAQ

### ssh/vscode 无法连接 docker

通过以下命令远程连接`$ ssh root@[your_host_ip] -p {host_port}` 如果报错

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ECDSA key sent by the remote host is
SHA256:AD5EKbZc0HJ5ZLsdfdfasdflEgSxa2w6wySKmiAbWYE.
Please contact your system administrator.
Add correct host key in C:\\Users\\username/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in C:\\Users\\username/.ssh/known_hosts:8
ECDSA host key for [172.xx.xx.1]:8025 has changed and you have requested strict checking.
Host key verification failed.
```

- 解决方法，删除`.ssh/known_hosts`对应 ip + port 地址的配置即可
- 原因:每个容器中的 ssh 都会生成唯一的 /etc/ssh/ssh_host_ecdsa_key.pub
  - 报错信息对应的`the ECDSA key` 通过命令 `ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key.pub`生成，当你变更了容器，但使用了相同的 port 端口，就会出现上面的报错，因为这个 key 对应不上了，系统怀疑是中间人攻击。


# 参考

- https://github.com/matthewfeickert/Docker-Python3-Ubuntu/blob/master/Dockerfile
- cpp https://github.com/feixiao/ubuntu_docker/blob/master/cpp_build/Dockerfile
- 各种 trick 集合 https://segmentfault.com/a/1190000021318326
- https://github.com/tecnickcom/alldev/blob/master/src/alldev/Dockerfile
- https://github.com/BrainTwister/docker-devel-env
