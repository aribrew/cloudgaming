#!/bin/bash

CURRENT_CLIENT=$(echo $SSH_CONNECTION | awk '{print $1}')

if ! [[ -v MOONLIGHT_CLIENT ]];
then
    MOONLIGHT_CLIENT="$CURRENT_CLIENT"
fi


if ! [[ -v MOONLIGHT_USER ]];
then
    echo -e "I NEED the user to use when talking with the Moonlight client.\n"
    exit 1
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


ANDROID_CLIENT=$(ssh user@${MOONLIGHT_CLIENT} "uname -a" | grep "Android")

if ! [[ "$ANDROID_CLIENT" == "" ]];
then
    ANDROID_CLIENT=1
fi


if [[ "$ANDROID_CLIENT" == "1" ]];
then
    SUNSHINE_HOST=""
else
    SUNSHINE_HOST="$HOSTNAME"
fi


APP_NAME$(echo "$APP_CMDLINE" | cut -d ' ' -f 1)

CMDLINE="moonlight stream $SUNSHINE_HOST Custom &> /dev/null"


echo -e "Trying to stream '$APP_NAME' to $MOONLIGHT_CLIENT...\n"

ssh ${MOONLIGHT_USER}@${MOONLIGHT_CLIENT} $CMDLINE

