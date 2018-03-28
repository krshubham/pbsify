#!/bin/bash

function init_pbs(){
  rm -rf ./pbspro
  git clone https://github.com/PBSPro/pbspro.git
}

function install_deps_ubuntu(){
  sudo apt-get install -y gcc make libtool libhwloc-dev libx11-dev \
      libxt-dev libedit-dev libical-dev ncurses-dev perl \
      postgresql-server-dev-all python-dev tcl-dev tk-dev swig \
      libexpat-dev libssl-dev libxext-dev libxft-dev autoconf \
      automake
  sudo apt-get install -y expat libedit2 postgresql python sendmail-bin \
  sudo tcl tk libical1a
}

function install_deps_CentOS(){
  yum install -y gcc make rpm-build libtool hwloc-devel \
      libX11-devel libXt-devel libedit-devel libical-devel \
      ncurses-devel perl postgresql-devel python-devel tcl-devel \
      tk-devel swig expat-devel openssl-devel libXext libXft \
      autoconf automake
    yum install -y expat libedit postgresql-server python \
      sendmail sudo tcl tk libical
}

function install_Ubuntu(){
  init_pbs
  install_deps_ubuntu
  cd ./pbspro
  ./autogen.sh
  if [ $? -eq 0 ]; then
    # to check if the program is working or not successfully
    ./configure --help
    if [ $? -eq 0 ]; then
      ./configure --prefix=/opt/pbs
      make
      makeRetValue = $?
      sudo make install
      # Before moving on check if this commadn
      if [[ $? -eq 0 && $makeRetValue -eq 0 ]]; then
        sudo /opt/pbs/libexec/pbs_postinstall
        sudo sed -i 's/\(^PBS_START_MOM=\).*/\11/' /etc/pbs.conf
    if [ $? -eq 0 ]; then
      sudo chmod 4755 /opt/pbs/sbin/pbs_iff /opt/pbs/sbin/pbs_rcp
      sudo /etc/init.d/pbs start
      . /etc/profile.d/pbs.sh
      qstat -B #end
      if [ $? -eq 0 ]; then
      echo "Installation complete";
      fi
      fi
    else
      echo "There is some error on line 26 of the script";
      return 0;
    fi
  else
    echo "There is some error on line 24 of the script, some commands didnt't work properly";
    return 0;
    fi
  fi
}

function install_CentOS(){
  install_deps_CentOS
  cd ./pbspro
  ./autogen.sh
  if [ $? -eq 0 ]; then
    # to check if the program is working or not successfully
    ./configure --help
    if [ $? -eq 0 ]; then
      ./configure --prefix=/opt/pbs #/opt is used for optional packages
      make
      makeRetValue = $?
      sudo make install
      # Before moving on check if this commadn
      if [[ $? -eq 0 && $makeRetValue -eq 0 ]]; then
        sudo /opt/pbs/libexec/pbs_postinstall
        sudo sed -i 's/\(^PBS_START_MOM=\).*/\11/' /etc/pbs.conf
    if [ $? -eq 0 ]; then
      sudo chmod 4755 /opt/pbs/sbin/pbs_iff /opt/pbs/sbin/pbs_rcp
      sudo /etc/init.d/pbs start
      . /etc/profile.d/pbs.sh
      qstat -B #end
      if [ $? -eq 0 ]; then
        echo "Installation complete";
      fi
      fi
    else
      echo "There is some error on line 26 of the script";
      return 0;
    fi
  else
    echo "There is some error on line 24 of the script, some commands didnt't work properly";
    return 0;
    fi
  fi
}

function install(){
  if [ $1 = "Ubuntu" ]; then
    install_Ubuntu
  elif [ $1 = "Darwin" ]; then
    echo "Not supported in your OS";
    exit 0
  elif [ $1 = "CentOS" ]; then
    echo "installing for CentOS";
    install_CentOS
  fi
}

sudo apt update
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi
install $OS