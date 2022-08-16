#!/usr/bin/env bash

set -e
FILE=server.jar

# shellcheck disable=SC2164
cd "$(dirname "$0")"

rcon () {
	/usr/bin/mcrcon -H owo.uwussi.moe -P 25575 -p "$RCONPASS" "$1"
}

_help() {
    echo "usage ${0} [options] [value]"
    echo
    echo " General options:"
    echo "    -f | --file [path]  Specify the file to read"
    echo "    -s | --shell        Enable shell mode"
    echo "    -h | --help         This help message and exit."
}

backup () {
    echo Sending signals to the server
    rcon "save-off"
    rcon "save-all"

    echo "Stopping minecraft server"
    sudo systemctl stop minecraft

    echo "Waiting for minecraft service to die"
    sleep 10

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
}

start () {
    if [ -f "$FILE" ]; then
        /usr/bin/java -Xmx1024M -Xms1024M -jar server.jar nogui
    else
        echo "Oops, there is no $FILE file to start the server."
        echo "Consider downloading one here: https://www.minecraft.net/en-us/download/server"
    fi
}

while true; do
    case "$1" in
        backup)
            backup
            ;;
        start)
            start
            ;;
        *)
            echo "Usage: $0 {backup|start}"
            exit 1
            ;;
    esac
done