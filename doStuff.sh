#! /bin/bash

function doBasic(){
	cd ~
	ls /media/dumps/linux-setups >&/dev/null
	errCheck $?

	ln -sf /media/dumps/linux-setups setups
	ln -sf /media/dumps/linux-setups/android/android-sdk-linux android
	echo 'alias APT="sudo apt-get update"'>>~/.bashrc
	echo 'alias APTU="sudo apt-get update && sudo apt-get upgrade"'>>~/.bashrc
	echo 'export PATH=$PATH:'$HOME/android/platform-tools>>~/.bashrc
	source ~/.bashrc
}

function installBasic(){
	sudo apt-get -y install software-properties-common vim git openssh-server
}

function addRep(){
	sudo add-apt-repository -y $1
}

function fixSources(){
	sudo sed -i /etc/sources.list 's/jessie/stable/g'
	APT
}

function errCheck(){
	if [[ $1 -ne 0 ]]
	then
		"An error occured!"
		exit 1
	fi	
}

function addVertexRepo(){
	echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/Debian_8.0/ /'|sudo tee -a /etc/apt/sources.list.d/vertex-theme.list > /dev/null
	wget http://download.opensuse.org/repositories/home:Horst3180/Debian_8.0/Release.key
	apt-key add - < Release.key
	rm Release.key
}

function getFonts(){
	ls setups >& /dev/null
	errCheck $?
	git clone https://github.com/powerline/fonts.git
	cd fonts
	./install.sh
}

function main(){
	if [[ $1 -eq 1 ]];then
		doBasic
		fixSources
		installBasic
		addVertexRepo
		APT
		sudo apt-get -y install ceti-2-theme vertex-theme arc-theme
		getFonts
		addRep "ppa:numix/ppa"
		addRep "ppa:no1wantdthisname/ppa"
		APT
		sudo apt-get -y install numix-icon-theme-circle fontconfig-infinality gnome-tweak-tool
	elif [[ $1 -eq 2 ]];then
		read -p "install gnome?(y/n)" resp
		if [[ $resp == "y" ]]; then
			echo 'APT::Install-Recommends "false";'|sudo tee -a /etc/apt/apt.conf >/dev/null
			APT
			sudo apt-get install xserver-xorg-input-synaptics xserver-xorg-video-intel gnome-session xorg nautilus gnome-terminal gnome-control-center gnome-tweak-tool alsa-utils pulseaudio gnome-themes gdm3 nautilus gksu gdebi file-roller unzip unrar
		fi
	elif [[ $1 -eq 3 ]];then
		APT
		wget http://font.ubuntu.com/download/ubuntu-font-family-0.83.zip
		unzip ubuntu-font-family-0.83.zip
		sudo mv ubuntu-font-family-0.83 /usr/share/fonts/
		sudo fc-cache -fv
		arch=$(uname -m)
		if [[ ! -e /usr/bin/google-chrome ]];then
			if [[ $arch == "i686" -o $arch == "i386" ]]; then
				wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
				sudo dpkg -i google-chrome-stable_current_i386.deb
			elif [[ $arch == "x86_64" ]]; then
				wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
				sudo dpkg -i google-chrome-stable_current_amd64.deb
			fi
			sudo apt-get -f install
		fi
		sudo apt-get -y install clementine guake firmware-linux-nonfree network-manager libreoffice-{impress,calc,writer} vlc smplayer

	elif [[ $1 -eq 4 ]];then
		wpa_passphrase $2 $3 > conf
		sudo wpa_supplicant -i wlan0 -BD wext -c conf
	fi
}

main $@
