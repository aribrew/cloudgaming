#!/bin/bash

# This script allow us to run any application in a remote Sunshine server
# without adding an application entry in it.
#
# You need to know the application name that launch the
# run_moonlight_cmdline.sh script.
#
# For SSHing into the server, you also
# need a valid user with it's password, or having a SSH key installed in
# the server.
#

# Server name or IP and user for SSH.
# Edit the exported variables with yours.

if ! [[ -v HOST_NAME ]];
then
    export HOST_NAME="sunshine"
fi

if ! [[ -v HOST_USER ]];
then
    export HOST_USER="user"
fi


# In Linux, set SUNSHINE_HOST and CMDLINE_APP names.
# In Termux (Android), you must write their UUIDs instead.
#
# For the server UUID, you can run the find_host_uuid.sh script
# providing the SSH connection string of your user in the Sunshine
# server, like 'user@host'.
#
# And for the CMDLINE_APP one, you need checking the app details
# details in the Moonlight/Artemis Android application.
#


if [[ -v TERMUX_VERSION ]];
then
    TMP="$HOME/tmp"

    export SUNSHINE_HOST="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
    export CMDLINE_APP="XXXXXXXXXX"
else
    TMP="/tmp"

    export SUNSHINE_HOST="sunshine"
    export CMDLINE_APP="Cmdline runner"
fi


check_cmdline()
{
    CMDLINE="$1"

    CMD=$(echo "$CMDLINE" | cut -d ' ' -f 1)

    echo -en "Checking if '$CMD' is available in the server... "

    CHECK=$(ssh ${HOST_USER}@${HOST_NAME} "source .environment; app_exists $CMD")

    if [[ "$CHECK" == "" ]];
    then
        echo -e "Something failed asking the server for the app...\n"
        exit 1

    elif [[ "$CHECK" == "No" ]];
    then
        echo -e "No.\n"
        exit 1
    else
        echo -e "Yes.\n"
    fi
}


send ()
{
	PACKAGE="$1"
	PACKAGE_DEST="$2"

	scp -q $PACKAGE ${HOST_USER}@${HOST_NAME}:$PACKAGE_DEST
}


start_moonlight()
{
    # Used for launching Moonlight after executing the script

	if [[ -v TERMUX_VERSION ]];
	then
        am start -n com.limelight/.ShortcutTrampoline \
                 --es "UUID" $SUNSHINE_HOST \
                 --es "AppId" $CMDLINE_APP
	else
	    "$MOONLIGHT" stream $SUNSHINE_HOST $CMDLINE_APP &> /dev/null &
	fi
}


usage()
{
	echo -e "Executes a command line in a Sunshine server."
	echo -e ""
	echo -e "Allows launching games and other things without creating"
	echo -e "a bunch of entries in the Sunshine's app list."
	echo -e ""
	echo -e "Usage: cloud_play.sh <command line>"
	echo -e ""
	echo -e "If the app needs setting environment variables"
	echo -e "add the needed exports in $CMDLINE_ENV_FILE file."
	echo -e ""
	echo -e "IMPORTANT: The $CMDLINE_ENV_FILE file will be DELETED after app"
	echo -e "closes. In other words: The environment is set just for this"
	echo -e "execution."
	echo -e ""
	echo -e "Before using the script, following variables must be set:"
	echo -e ""
	echo -e "HOST_NAME, HOST_USER: Server SSH host and user"
	echo -e "MOONLIGHT: The path to the Moonlight app, if using in Linux"
	echo -e "SUNSHINE_HOST: The name or IP of the Sunshine server"
	echo -e "CMDLINE_APP: The name of the app used to send the command line"
	echo -e ""
	echo -e "The SSH variables can be overriden upon execution."
	echo -e "Also, there is no password field. Using SSH keys is better."
	echo -e ""
}




if [[ "$1" == "" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]];
then
    usage
    exit 1
fi


export MOONLIGHT="$HOME/Apps/Moonlight-6.1.0-x86_64.AppImage"



if ! [[ -d "$TMP" ]];
then
    mkdir -p "$TMP"
fi


export CMDLINE_FILE="$TMP/sunshine_cmdline"
export CMDLINE_ENV_FILE="$TMP/sunshine_cmdline_env"

# The cmdline and env file paths must match the one
# set in the MOONLIGHT_CMDLINE variable, located in the
# run_moonlight_cmdline.sh script at server side

REMOTE_CMDLINE_FILE="/tmp/moonlight_cmdline/cmdline"
REMOTE_ENV_FILE="/tmp/moonlight_cmdline/env"


CMDLINE=${@:1}


if [[ "$CMDLINE" == "" ]];
then
    echo -e "Need a command line to send.\n"
    exit 1
fi


check_cmdline "$CMDLINE"


echo "$CMDLINE" > "$CMDLINE_FILE"
send "$CMDLINE_FILE" "$REMOTE_CMDLINE_FILE"


if [[ -f "$CMDLINE_ENV_FILE" ]];
then
    send "$CMDLINE_ENV_FILE" "$REMOTE_ENV_FILE"
fi


start_moonlight

echo -e "Executing '$CMDLINE' in $SUNSHINE_HOST ..."


if [[ -f "$CMDLINE_ENV_FILE" ]];
then
    rm "$CMDLINE_ENV_FILE"
fi

rm "$CMDLINE_FILE"
