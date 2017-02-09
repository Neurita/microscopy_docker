
#FROM debian:jessie
FROM ubuntu:16.04
MAINTAINER Alexandre Savio <alexsavio@gmail.com>

RUN ln -snf /bin/bash /bin/sh

ARG DEBIAN_FRONTEND=noninteractive


ENV PYENV_NAME pytre
ENV N_CPUS 2
## Configure default locale

# utils for local testing
# ENV() { export $1=$2; }; COPY() { cp -rdv $1 $2; };

# Debian
#RUN apt-get update && \
#    apt-get -y install apt-utils locales && \
#    dpkg-reconfigure locales && \
#    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
#    locale-gen

# Ubuntu
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.utf8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8

# Set environment
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV TERM xterm

ENV HOME /work
ENV SOFT $HOME/soft
ENV BASHRC $HOME/.bashrc

# Create a non-priviledge user that will run the services
ENV BASICUSER basicuser
ENV BASICUSER_UID 1000

RUN useradd -m -d $HOME -s /bin/bash -N -u $BASICUSER_UID $BASICUSER && \
    mkdir $SOFT && \
    mkdir $HOME/.scripts && \
USER $BASICUSER
WORKDIR $HOME

# Add files.
COPY root/.* $HOME/
COPY root/* $HOME/
COPY root/.scripts/* $HOME/.scripts/

# neurodebian and Install.
USER root
RUN \
    chown -R $BASICUSER $HOME && \
    echo "export SOFT=\$HOME/soft" >> $BASHRC && \
    apt-get update && \
    apt-get install -y wget bzip2 unzip htop curl git && \
    sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
cmake \
gcc-4.9 \
g++-4.9 \
gfortran-4.9 \
tcsh \
libjpeg62 \
libxml2-dev \
libxslt1-dev \
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5   40 --slave /usr/bin/g++ g++ /usr/bin/g++-5 && \
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9 && \
rm -rf /var/lib/apt/lists/*

 2001  sudo apt-get build-dep python3
 2002  dh -
 2003  df -h
 2004  sudo apt-get install libncurses5-dev
 2005  sudo apt-get install libbz2-dev
 2006  sudo apt-get install libgdm-dev
 2007  apt-cache search dbm
 2008  sudo apt-get install libqdbm-dev
 2009  apt-cache search tkinter
 2010  sudo apt-get install libncursesw5-dev
 2011  sudo apt-get install libz-dev libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libdb-dev liblzma-dev
 2012  sudo pip install pyenv
 2013  sudo pip3 install pyenv
 2014  pip3
 2015  sudo apt-get install python3-pip
 2016  sudo pip3 install pyenv
 2017  sudo pip3 install -U pip
 2018  sudo pip3 install -U setuptools
 2019  sudo pip3 install -U virtualenvwrapper
 2020  sudo pip3 install -U pyenv

#-------------------------------------------------------------------------------
# CPython
#-------------------------------------------------------------------------------
WORKDIR $SOFT
RUN \
    mkdir cpython && \
    cd cpython && \
    git clone $CPYTHON_GIT -b $CPYTHON_VERSION CPYTHON && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          ../DCM2NIIX && \
    make -j $N_CPUS && \
    make install && \
    cd ../.. && \
    rm -rf dcm2niix


#-------------------------------------------------------------------------------
## Here start the libraries that won't be installed in /usr/local
USER $BASICUSER

#-------------------------------------------------------------------------------
# Python environment with virtualenvwrapper
#-------------------------------------------------------------------------------
# Install Python 3 from miniconda

ENV PATH="$HOME/miniconda/bin:$PATH"

WORKDIR $SOFT
RUN \
  wget -O miniconda.sh \
     https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
  bash miniconda.sh -b -p $HOME/miniconda && \
  rm miniconda.sh && \
  echo "addpath \$HOME/miniconda/bin" >> $BASHRC && \
  conda update -y python conda && \
  conda config --add channels conda-forge && \
  conda install -y --no-deps \
matplotlib \
cycler \
freetype \
libpng \
pyparsing \
pytz \
python-dateutil \
six \
pip \
setuptools \
cython \
numpy \
scipy \
pandas \
scipy \
scikit-learn \
scikit-image \
statsmodels \
networkx \
pillow \
openblas \
&& conda clean -tipsy

# Install the other requirements
RUN pip install -r $HOME/requirements.txt && \
    rm -rf ~/.cache/pip/ && \
    source $BASHRC

#-------------------------------------------------------------------------------
# source .bashrc
#-------------------------------------------------------------------------------
USER root
RUN ldconfig

CMD ["/bin/bash"]
