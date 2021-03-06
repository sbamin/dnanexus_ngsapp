#!/bin/bash
## userud mapping script at docker startup ##
# 12-2018 | @sbamin
# v 1.2

##### set USER ID mapping #####

## Set defaults for environmental variables in case they are undefined
HOSTUSER=${HOSTUSER:=pallidus}
HOSTGROUP=${HOSTGROUP:=evo}
HOSTUSERID=${HOSTUSERID:=2119518}
HOSTGROUPID=${HOSTGROUPID:=712119}
ROOTGRP=${ROOTGRP:=FALSE}

if [[ "$HOSTUSERID" -ne 2119518 && "${HOSTGROUPID}" -ne 712119 ]]; then
	## Configure user with a different HOSTUSERID and HOSTGROUPID if requested.
	echo "Create new user to map host user: $HOSTUSER with UID $HOSTUSERID and GID $HOSTGROUPID"
	# create new group identical to host group id and name
	groupadd -g "${HOSTGROUPID}" "${HOSTGROUP}"
	# create new user identical to host user, including UID and GID
	useradd -m -d /home/"${HOSTUSER}" -s /bin/bash -c "Docker User" -u "${HOSTUSERID}" -g "${HOSTGROUP}" -G users,staff "${HOSTUSER}"
fi

# Use Env flag to know if user should be added to sudoers
if [ "$ROOTGRP" == "TRUE" ]; then
		# add host user to sudo inside docker container
		## DANGER: sudoers already have passwordless access inside docker. Use sudo command with caution!
		usermod -a -G sudo "${HOSTUSER}"
		echo -e "\n\033[33;5;7m#### CAUTION ####\033[0m\nHOSTUSER: $HOSTUSER has sudo privileges while running docker container."
		echo -e "\nThis can potentially change host system's file system, including root owned contents."
		echo -e "\nAvoid recursive change in file permissions and deletions.\n############\nWaiting 5 seconds....."
		sleep 5
fi

## source /etc/profile
. /etc/profile

## at the last, change shell to host HOSTUSER environment and run init script
## pass user supplied args at docker run command, if any
runuser -g "${HOSTGROUP}" "${HOSTUSER}" -c "$@"

## END ##
