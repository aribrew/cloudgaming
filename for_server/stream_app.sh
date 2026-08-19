#!/bin/bash

# This script is intended for running an application in a Sunshine
# server and, right after that, launch Moonlight/Artemis in the
# connected client to start the streaming.
#


# Obtain the connected client's IP
CURRENT_CLIENT=$(echo $SSH_CONNECTION | awk '{print $1}')

# If no MOONLIGHT_CLIENT IP was exported, use the detected one
if ! [[ -v MOONLIGHT_CLIENT ]];
then
    MOONLIGHT_CLIENT="$CURRENT_CLIENT"
fi


# We also need the user to use when SSHing into the connected client
if ! [[ -v MOONLIGHT_USER ]];
then
    echo -e "I NEED the user to use when talking with the Moonlight client.\n"
    exit 1
fi


# Check if the connected client is using Android
ANDROID_CLIENT=$(ssh user@${MOONLIGHT_CLIENT} "uname -a" | grep "Android")

if ! [[ "$ANDROID_CLIENT" == "" ]];
then
    export CMDLINE_APP="CMDLINE_APP_UUID"
else
    export CMDLINE_APP="CMDLINE_APP_NAME"
fi


APP_CMDLINE=${@:1}

if [[ "$APP_CMDLINE" == "" ]];
then
    echo -e "I need something to stream...\n"
    exit 1
fi

if ! [[ -d "$HOME/tmp/moonlight_cmdline" ]];
then
    mkdir -p "$HOME/tmp/moonlight_cmdline"
fi

echo "$APP_CMDLINE" > "$HOME/tmp/moonlight_cmdline/cmdline"

if [[ -v APP_ENV ]];
then
    echo "$APP_ENV" > "$HOME/tmp/moonlight_cmdline/env"
fi


APP_NAME$(echo "$APP_CMDLINE" | cut -d ' ' -f 1)


if [[ "$ANDROID_CLIENT" == "1" ]];
then
    SUNSHINE_HOST=""
else
    CMDLINE="moonlight stream $SUNSHINE_HOST $CMDLINE_APP &> /dev/null"
    SUNSHINE_HOST="$HOSTNAME"
fi


echo -e "Trying to stream '$APP_NAME' to $MOONLIGHT_CLIENT...\n"

ssh ${MOONLIGHT_USER}@${MOONLIGHT_CLIENT} $CMDLINE
