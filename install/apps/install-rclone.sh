#!/bin/bash

which rclone > $CONFIGS/.config/checkapp.txt
clear

if [ -s $CONFIGS/.config/checkapp.txt ]; then

	ALREADYINSTALLED

else

	EXPLAINTASK

	CONFIRMATION

	if [[ ${REPLY} =~ ^[Yy]$ ]]; then

		GOAHEAD
		RUNPATCHES

		# Install MergerFS (for future use)

		lsb_release -r -s > /tmp/version
		VERSION=$( cat /tmp/version )

		if [ "$VERSION" = "18.04" ]; then sudo apt-get -y install mergerfs; fi

		rm /tmp/version

		# Main script

		cd /tmp
		
		clear

		read -e -p "Release ${YELLOW}(R)${STD} or Beta installation ${YELLOW}(B)?${STD} " -i "R" choice

		case "$choice" in 
			b|B ) curl https://rclone.org/install.sh | sudo bash -s beta ;;
			* ) curl https://rclone.org/install.sh | sudo bash ;;
		esac

		clear

		echo "${YELLOW}Please follow the instructions to setup Rclone${STD}"
		echo ""
		sudo rclone config

		# Installing Services

		sudo mkdir -p /var/local/GooPlex/.config
		sudo mkdir -p $HOME/logs
		sudo mkdir /media/Google

		sudo rsync -a $HOME/.config/rclone/rclone.conf $CONFIGS/.config
		sudo rsync -a /opt/GooPlex/scripts/rclone.service /etc/systemd/system/rclone.service

		sudo chown -R $USER:$USER $CONFIGS/.config
		sudo chown -R $USER:$USER $CONFIGS/$HOME
		sudo chown -R $USER:$USER /media/Google

		sudo systemctl enable rclone.service
		sudo systemctl daemon-reload
		sudo systemctl start rclone.service

		TASKCOMPLETE

	else

		CANCELTHIS

	fi

fi

rm $CONFIGS/.config/checkapp.txt
PAUSE