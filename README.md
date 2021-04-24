# Docker开发环境
适用场景: window 或 mac 通过vscode远程连接使用安装了docker环境的linux服务器进行开发，用户可基于此 Dockerfile 修改并创建自己的镜像

* 某些场景下搭建开发环境很耗时，有docker能够显著减少配置环境所花费的时间，例如当你
    * 拥有多个开发服务器和需要不同开发环境的项目
    * 开发环境配置复杂，而且希望他人能够复用
    * 换了工作，电脑，需要重新配置
    * ...
## 特性
* vscode
    * 配置openssh，拷贝id_rsa，可以通过 vscode 连接 docker 远程开发
* 好用的终端配置
    * oh-my-zsh 与插件
    * [fzf](https://github.com/junegunn/fzf.git) 模糊搜索和跳转文件夹
    * [vimrc](https://github.com/amix/vimrc.git) 
    * tmux
    * htop
    * git 配置
* C++ 安装了 cmake / bazel
* python 更新镜像源，安装常见包，flake8用于语法检查，black用于代码格式化
* 用户权限 
    * docker中创建了跟宿主机用户相同权限和名称的账户
    * 该账户在docker内有sudo权限，免密码
    * 该账户与root共享HOME目录，以及上述的zsh等配置
* 基本的初始化
    * 中文时区 + 中文编码
    * 基础包 如 curl git vim
* 事先下载github的安装包，避免后续构建出现网络问题

## 使用
简而言之，选择一个基于ubuntu系统的基础镜像，然后通过Dockerfile构建开发环境的镜像，最后通过vscode连接容器进行开发

0. `./download.sh` 首先下载相关的库，避免之后构建镜像时遇到网络问题
1. 进入`build_image.sh`中按照提示修改成符合自己的配置
    * 可以修改Dockerfile的基础镜像（目前在ubuntu18和tf2.+ docker 中测试通过）
        * 如果使用 pytorch 的 ubuntu18镜像，需要修改python的路径
    * requirements.txt 改为自己常用的python包
2. 查看 `Dockerfile`, 删除不需要的配置，例如基础镜像中已经有python，可以删掉python部分
3. `./build_image.sh`构建镜像
4. `./run_container.sh`根据镜像创建一个开发容器
5. vscode远程连接容器
    * 安装 vscode remote 插件，
    * 在C:\Users\username\.ssh\config 文件中 参照如下格式修改
    ```
    Host hostname
      HostName your_remote_server_ip
      User $user
      Port $host_port
    ```
6. 配置远程vscode
    1. 安装插件: 可以手动在extension页面中点击远程安装，也可以`ctrl+shift+P`输入`install local extensions in` remote 来一次性安装所有插件。
    2. 修改配置
        1. 例如 python项目 .vscode/setting.json 中，修改 `python.pythonPath`为docker中的`/usr/bin/python3`
7. 可以将配置好vscode的容器通过 `docker commit [container_id] [image_name]`再存为一个镜像，避免后续重复配置vscode，PS: vscode远程无法通过脚本安装，[原因](https://code.visualstudio.com/docs/remote/faq#_can-vs-code-server-be-installed-or-used-on-its-own)
## FAQ
### ssh/vscode 无法连接docker
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
* 解决方法，删除`.ssh/known_hosts`对应ip + port地址的配置即可
* 原因:每个容器中的ssh都会生成唯一的 /etc/ssh/ssh_host_ecdsa_key.pub
    * 报错信息对应的`the ECDSA key` 通过命令 `ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key.pub`生成，当你变更了容器，但使用了相同的port端口，就会出现上面的报错，因为这个key对应不上了，系统怀疑是中间人攻击。

## 使用技巧
有时间的话，建议到相应的github仓库去看使用说明，下面仅介绍简要的功能

### fzf
来源: https://github.com/junegunn/fzf#key-bindings-for-command-line

`Alt+C` 快速跳转文件夹是我最喜欢的功能，不过你需要在vscode `ctrl k + ctrl s`打开快捷键设置，将冲突的快捷键（默认是toggle搜索的大小写敏感）删除，就可以在终端中使用这个快捷键了

* `alt+c` 模糊搜索HOME下文件夹，实现快速跳转 （HOME路径可在 `build_image` 的 fzf_search_dir中配置）
* `ctrl+t` 模糊搜索HOME下文件，快速得到文件路径，在vscode终端下，我经常使用 `code -r ctrl+T` 的方式来快速访问文件
* `vi **[tab]` 模糊搜索当前路径下的文件，并用vim打开
* `cd **[tab]` 模糊搜索当前路径下的文件夹，并跳转

### oh my zsh
来源: https://github.com/ohmyzsh/ohmyzsh

* 安装了自动补全，高亮等插件
* alias 命令别名
    * `gst` git stats
    * `gco` git checkout
    * `gcmsg` git commit -m
    * ...还有一大堆...
    * 请阅读: https://github.com/ohmyzsh/ohmyzsh/wiki/Cheatsheet

### vimrc
来源: https://github.com/amix/vimrc

如果期望有自动补全，还可以参考 scripts 下安装 YouCompleteMe

cheat-sheet

0. 翻页
    `ctrl d` 向下翻半页，注意 **ctrl f** 被绑定为搜索了，所以无法使用ctrl f 翻页
    `ctrl u` 向上翻半页
1.  全局查找文件(ctrlp插件)  
    `ctrl + f` --打开全局文件搜索面板  
    `Esc` --退出全局文件搜索面板
2.  tab(标签)相关  
    `gt` --后一个标签  
    `gT` --前一个标签  
    `num` + gt --跳转至第num个标签  
    `,tl` --上一次的标签  
    `:q` --关闭标签  
    `:Te` --新建标签，并打开当前文件目录  
    `,tn` --新建空白标签
3.  目录树(NERD\_tree插件)  
    `,nn` --打开目录树  
    `,nn` --关闭目录树
4.  窗口相关  
    `ctrl + w + q` --关闭窗口  
    `:q` --关闭窗口，窗口只有一个tab的情况  
    `ctrl + w + w` --切换窗口  
    `:sp` --竖直方向上拆分当前窗口  
    `:vsp` --水平方向上拆分当前窗口
5.  如何打开一个工程  
    在某个工程的根目录下输入打开vim，则该vim窗口的文件操作默认为整个工程，比如全局搜索文件或字段
6.  全局搜索字段(ack插件)  
    `,g` --打开全局字段搜索面板，默认大小写敏感，-i 不区分大小写，-w 全词匹配  
    `q` --退出全局字段搜索面板
7.  当前文件所在的目录  
    `:E` --打开当前目录，一般用于切换当前目录的文件  
    `:Te` --新建标签并打开当前目录，一般用于打开当前目录下的其它文件
8.  查看最近打开的文件列表  
    `,f` --打开面板  
    `q` --退出面板
9.  当前文件下搜索  
    `*`\--按下即可搜索光标所在的单词或当前选中的内容，不区分大小写  
    `gd` --光标移动至单词，按下即可搜索该单词，区分大小写  
    `/` --输入单词向下搜索  
    `?` --输入单词向上搜索，一般用于查log，配合G跳转至文件底部使
10.  显示行修改标志  
    `,d` --显示与不显示逐一切换
11.  光标停留的位置记录  
    `ctrl + o` --上一个时间点光标停留的位置  
    `ctrl + i` --下一个时间点光标停留的位置
12.  文件刷新，即重新载入  
    `:e` --重新载入  
    `:e!` --放弃当前修改，强制重新载入  
    `:e file_dir` --载入 file\_dir 路径下的某个文件
13.  粘贴0号寄存器的内容  
    `ctrl + r + 0` --比如y复制选中的内容后粘贴到命令输入框
14.  折叠命令  
    `za` --打开或关闭当前折叠  
    `zM` --关闭所有折叠  
    `zR` --打开所有折叠
15.  跳出双引号继续编辑  
    有些时候输入完字符串需要移动光标至双引号外继续输入  
    `"` --在 " 处输入 " ，即可将光标跳转至当前双引号之外
16.  文件路径  
    `:f` --查看当前文件路径
17.  变量名补全  
    `ctrl + n` --自动补全变量名，再次输入匹配下一个
18.  代码块补全，只需输入部分代码，然后按tab键  
    lua为例：  
    `if + tab` --if代码块  
    `forp + tab` --for i,v in pairs() do end 代码块  
    `fori + tab` --for i,v in ipairs() do end 代码块  
    `fun + tab` --函数模板代码块
19.  代码检错  
    `:ALEToggle` --启动检错
20.  代码注释  
    `gcc` --注释当前行，再次输入则撤销注释  
    `num + gcc` --注释num行  
    `gc` --注释选中部分



# 参考
* https://github.com/matthewfeickert/Docker-Python3-Ubuntu/blob/master/Dockerfile
* cpp https://github.com/feixiao/ubuntu_docker/blob/master/cpp_build/Dockerfile
* 各种trick集合 https://segmentfault.com/a/1190000021318326
* https://github.com/tecnickcom/alldev/blob/master/src/alldev/Dockerfile
* https://github.com/BrainTwister/docker-devel-env
