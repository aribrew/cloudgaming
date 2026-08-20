#!/bin/bash

# This script is intended for running an application in a Sunshine
# server and, right after that, launch Moonlight/Artemis in the
# connected client to start the streaming.
#


find_sunshine_uuid()
{
    SUNSHINE_STATE_FILE_PATH="~/.config/sunshine/sunshine_state.json"

    if ! [[ -f "$SUNSHINE_STATE_FILE_PATH" ]];
    then
        SS_DATA=""
    else
        SS_DATA=$(cat $SUNSHINE_STATE_FILE_PATH)
    fi

    if ! [[ "$SS_DATA" == "" ]];
    then
        UUID=$(echo "$SS_DATA" | grep "uniqueid")
        UUID=$(echo "$UUID" | cut -d ':' -f 2 | cut -d ',' -f 1 | xargs)

        if ! [[ $(echo "$UUID" | cut -d '-' -f 5) == "" ]];
        then
            echo "$UUID"
        fi
    fi
}


# Obtain the connected client's IP
CURRENT_CLIENT=$(echo $SSH_CONNECTION | awk '{print $1}')

# If no MOONLIGHT_CLIENT IP is provided, use the detected one
if ! [[ -v MOONLIGHT_CLIENT ]];
then
    MOONLIGHT_CLIENT="$CURRENT_CLIENT"
fi


SUNSHINE_UUID=$(find_sunshine_uuid)

if [[ "$SUNSHINE_UUID" == "" ]];
then
    echo -e "This isn't a Sunshine host.\n"
    exit 1
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
    if ! [[ -v CMDLINE_APP_UUID ]];
    then
        echo "I NEED the CMDLINE_APP_UUID for launching the app in Android."
        exit 1
    fi
else
    if ! [[ -v CMDLINE_APP_NAME ]];
    then
        echo "I NEED the CMDLINE_APP_NAME for launching the app."
        exit 1
    fi
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


APP_NAME=$(echo "$APP_CMDLINE" | cut -d ' ' -f 1)


if ! [[ "$ANDROID_CLIENT" == "" ]];
then
    CMDLINE="am start -n com.limelight/.ShortcutTrampoline \
             --es "UUID" $SUNSHINE_UUID \
             --es "AppId" $CMDLINE_APP_UUID"
else
    CMDLINE="moonlight stream $SUNSHINE_HOST $CMDLINE_APP_NAME &> /dev/null"
fi


echo -e "Trying to stream '$APP_NAME' to $MOONLIGHT_CLIENT...\n"

ssh ${MOONLIGHT_USER}@${MOONLIGHT_CLIENT} $CMDLINE
