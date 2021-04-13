# YouCompleteMe + ubuntu 18 安装脚本

apt install build-essential cmake vim-nox python3-dev
apt install mono-complete golang nodejs default-jdk npm
# 更新 gcc 版 > 8， ubuntu 18 默认7.5 好像
# 以下命令参考: https://askubuntu.com/questions/1028601/install-gcc-8-only-on-ubuntu-18-04
# Dockerfile可以参考 : https://gist.github.com/application2000/73fd6f4bf1be6600a2cf9f56315a2d91
apt install dpkg-dev g++-8 gcc-8 libc6-dev libc-dev make
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 700 --slave /usr/bin/g++ g++ /usr/bin/g++-7
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8

# YouCompleteMe 需要 vim 8.1 版本.... ubuntu 安装的是 8.0 版本...
sudo add-apt-repository ppa:jonathonf/vim -y
sudo apt update
sudo apt install -y vim

# 更新 cmake 版本: CMake 3.14 or higher
pip install cmake
echo "export PATH=\"/root/.local/bin:$PATH\""
export PATH="/root/.local/bin:$PATH" # 上面的步骤会将cmake安装到这个路径下 添加到 zshrc 中

git clone --recurse-submodules https://github.com/ycm-core/YouCompleteMe /root/.vim_runtime/sources_non_forked
cd /root/.vim_runtime/sources_non_forked/YouCompleteMe
# 为了避免后续仓库升级不必要的麻烦，指定 这个版本能生效的 commit 版本号
git checkout a3d02238ca5c19a64ff3336087fe016a4137fde9
# python3 install.py --all 需要在线下载一些东西..
python3 install.py 

# 如果是window git clone的，所以还需要解决 换行问题.. ^M
sudo apt-get install tofrodos; sudo ln -s /usr/bin/fromdos /usr/bin/dos2unix ; 
dos2unix /root/.vim_runtime/sources_non_forked/YouCompleteMe/plugin/youcompleteme.vim
dos2unix /root/.vim_runtime/sources_non_forked/YouCompleteMe/autoload/youcompleteme.vim
