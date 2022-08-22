#!/bin/bash

# shellcheck disable=SC2164
cd "$(dirname "$0")"

function rcon {
	/usr/bin/mcrcon -H owo.uwussi.moe -P 25575 -p "$RCONPASS" "$1"
}

echo Sending signals to the server
rcon "save-off"
rcon "save-all"

# Uploading Git Changes
if [ "$(git status --porcelain)" ]; then
	echo "There are changes in the data folder. Committing them..."
	git add .
	git commit -m "Sync from local to remote $RANDOM"

	sshpass -P passphrase -p $SSHPASS git push
fi

echo "Starting the server"
sudo systemctl start minecraft

echo Waiting for the server to startup
sleep 60

echo Sending save stats signal
rcon "save-on"
