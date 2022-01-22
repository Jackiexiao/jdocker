mkdir -p cache
wget https://github.com/ohmyzsh/ohmyzsh/archive/refs/heads/master.zip -O cache/ohmyzsh-master.zip
wget https://github.com/junegunn/fzf/archive/refs/heads/master.zip -O cache/fzf-master.zip
wget https://github.com/junegunn/fzf/releases/download/0.26.0/fzf-0.26.0-linux_amd64.tar.gz -P cache/
wget https://github.com/amix/vimrc/archive/refs/heads/master.zip -O cache/vimrc-master.zip
wget https://github.com/zsh-users/zsh-autosuggestions/archive/refs/heads/master.zip -O cache/zsh-autosuggestions-master.zip
wget https://github.com/zsh-users/zsh-completions/archive/refs/heads/master.zip -O cache/zsh-completions-master.zip
wget https://github.com/zsh-users/zsh-syntax-highlighting/archive/refs/heads/master.zip -O cache/zsh-syntax-highlighting-master.zip
wget https://github.com/bazelbuild/bazel/releases/download/4.0.0/bazel-4.0.0-installer-linux-x86_64.sh -P cache/
wget https://github.com/bazelbuild/buildtools/releases/download/4.0.1/buildifier-linux-amd64 -P cache/
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -P cache/
wget https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py -P cache/
wget https://github.com/sharkdp/fd/releases/download/v8.2.1/fd-musl_8.2.1_amd64.deb -P cache/