# 下载必要的安装包，避免后续构建docker镜像出现网络问题
mkdir -p cache
wget https://github.com/ohmyzsh/ohmyzsh/archive/refs/heads/master.zip cache
wget https://github.com/junegunn/fzf/archive/refs/heads/master.zip cache
wget https://github.com/junegunn/fzf/releases/download/0.26.0/fzf-0.26.0-linux_amd64.tar.gz cache
wget https://github.com/amix/vimrc/archive/refs/heads/master.zip cache
wget https://github.com/zsh-users/zsh-autosuggestions/archive/refs/heads/master.zip cache
wget https://github.com/zsh-users/zsh-completions/archive/refs/heads/master.zip cache
wget https://github.com/zsh-users/zsh-syntax-highlighting/archive/refs/heads/master.zip cache
wget https://github.com/bazelbuild/bazel/releases/download/4.0.0/bazel-4.0.0-installer-linux-x86_64.sh cache

# bazel 的工具
wget https://github.com/bazelbuild/buildtools/releases/download/4.0.1/buildifier-linux-amd64 cache
git clone https://github.com/grailbio/bazel-compilation-database cache/bazel-compilation-database