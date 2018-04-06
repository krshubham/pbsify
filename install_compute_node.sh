# @Author: krshubham
# @Date:   2018-04-06 04:07:40
# @Last Modified by:   Kumar Shubham
# @Last Modified time: 2018-04-06 04:56:01
#This script is for configuring a compute node

function make_sure_sudo_no_password(){
	#Make sure that the user has sudo privileges without any password
	sudo -n true
	if [ $? -eq 0 ]; then
		echo "Running updates ....";
	else
		echo "You do not have permission to run this script";
	return 127;
}

function apt_update_check(){
	sudo apt update
}

function install_all_deps(){
	sudo apt-get install -y gcc make libtool libhwloc-dev libx11-dev \
      libxt-dev libedit-dev libical-dev ncurses-dev perl \
      postgresql-server-dev-all python-dev tcl-dev tk-dev swig \
      libexpat-dev libssl-dev libxext-dev libxft-dev autoconf \
      automake
  sudo apt-get install -y expat libedit2 postgresql python sendmail-bin \
  sudo tcl tk libical1a
}

#Make sure git is installed before running this
function download_PBSPro(){
	#remove the pbspro directory if it exists already and start fresh
	rm -rf ./pbspro
	git clone https://github.com/PBSPro/pbspro.git
}

function start_installation(){
	cd ./pbspro
	./autogen.sh
	./configure --prefix=/opt/pbs
	make
	sudo make install
	sudo /opt/pbs/libexec/pbs_postinstall
	#only start MOM on the compute node and stop everything else
    sudo sed -i 's/\(^PBS_START_SERVER=\).*/\10/' /etc/pbs.conf
    sudo sed -i 's/\(^PBS_START_COMM=\).*/\10/' /etc/pbs.conf
    sudo sed -i 's/\(^PBS_START_SCHED=\).*/\10/' /etc/pbs.conf
    sudo sed -i 's/\(^PBS_START_MOM=\).*/\11/' /etc/pbs.conf
    sudo chmod 4755 /opt/pbs/sbin/pbs_iff /opt/pbs/sbin/pbs_rcp
    sudo rm -rf /var/spool/pbs/mom_priv/config
    #copy this config file for the compute node
    sudo cp ./mom_priv.config.sample /var/spool/pbs/mom_priv/config
    sudo /etc/init.d/pbs start
}
