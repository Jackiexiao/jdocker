######################################################
####  安装 jupyterlab + xeus-cling 与其配套环境  ####
######################################################

# 安装 miniconda with python 3.8 来源: https://docs.conda.io/en/latest/miniconda.html
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh 

# 安静的安装: 参考: https://docs.anaconda.com/anaconda/install/silent-mode/
bash Miniconda3-latest-Linux-x86_64.sh -b 
# -b 可以安静的，全部默认选项地安装，若指定位置: 添加 -p /some/path
# 添加到系统路径
eval "$('/root/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# 避免shell启动的时候自动进入 base conda
conda config --set auto_activate_base false
# 使用 conda-forge 源头
conda config --add channels conda-forge
# 进入 base conda # 如果前面没设置为 false 就不用
conda activate
# memba
conda install -c conda-forge mamba -y

# jupyterlab 3.0
mamba install -c conda-forge jupyterlab -y

# xeus-cling # C++ 类似 jupyter python 服务
mamba install xeus-cling -c conda-forge -y

# jupyterlab Kite 自动补全 插件， 来源 : https://github.com/kiteco/jupyterlab-kite
bash -c "$(wget -q -O - https://linux.kite.com/dls/linux/current)"
pip install jupyterlab-kite

# 启动 jupyter lab 服务
jupyter lab --no-browser  --ip=0.0.0.0 --NotebookApp.token="" 


##################
####  注意事项  ####
##################
# PS 在非纯净的 pip 中安装上述软件 很容易遇到问题... 例如  kite

# 问题排查
# kite 安装
# https://github.com/kiteco/issue-tracker/issues/730#issuecomment-823116154

##################
####  插件  ####
##################

# 另一种安装插件的方法
# jupyter labextension install @jupyterlab/...

# 插件推荐
# jupyter-matplotlib
# jupyterlab-debugger
# jupyterlab-plotly
# jupyterlab-topbar-extension
# jupyterlab-system-monitor
# JupyterLab Execution Time

##################
####  nodejs ####
##################

# 如果插件 需要 node.js 和 npm
# 安装方法
# ```
# sudo apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates
# curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
# sudo apt -y install nodejs
# ```

##################
####  快捷键 ####
##################

# Jupyter Lab 快捷键
# ctrl shift [ / ] 切换tab页
# Ctrl+Shift+L 打开起始页
# Ctrl+s 保存
# Alt+w 关闭当前打开页
# Shift+Enter 运行选中的cells（可以有多个）
# X 剪切选中的cell
# C 复制选中的cell
# V 粘贴选中的cell
# 双击D 删除选中的cell