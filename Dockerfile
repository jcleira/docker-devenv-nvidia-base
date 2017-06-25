FROM nvidia/cuda
LABEL maintainer "jmc.leira@gmail.com"

# Install development tools.
RUN apt-get update && apt-get install -y \
  # Base dependencies.
  build-essential \
  git \
  cmake \
  locales \
  curl \
  # oh-my-zsh dependencies.
  zsh \
  #YouCompleteme dependencies
  libncurses5-dev \
  libncursesw5-dev \
  nodejs \
  npm \
  # AWS cli dependencies
  python-pip && \
  pip install --upgrade pip


# Configure locales.
ENV DEBIAN_FRONTEND noninteractive
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install vim from github
RUN git clone https://github.com/vim/vim.git /tmp/vim && \
  cd /tmp/vim && \
  ./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-pythoninterp=yes \
            --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
            --enable-python3interp=yes \
            --with-python3-config-dir=/usr/lib/python3.5/config-3.4m-x86_64-linux-gnu \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk2 --enable-cscope --prefix=/usr && \
  make && make install

# Install the AWS cli console
RUN pip install awscli

# We do also force the 2000 UID to match the host
# user and avoid permissions problems.
# There are some issues about it:
# https://github.com/docker/docker/issues/2259
# https://github.com/nodejs/docker-node/issues/289
RUN  useradd -ms /bin/bash dev && \
  usermod -o -u 2000 dev

# Set the working dir
WORKDIR /home/dev

# Run from the dev user.
USER dev

RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
  ~/.fzf/install --bin

# Configure custom preferences using dotfiles.
RUN git clone https://github.com/jcorral/dotfiles.git ~/Code/dotfiles  && \
  cd ~/Code/dotfiles && \
  git submodule update --init --recursive && \
  ./configure.sh

# Install oh-my-zsh
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

RUN ~/Code/dotfiles/.vim/bundle/YouCompleteMe/install.py --tern-completer
