#!/bin/bash

CONN_STRING="$1"

SUNSHINE_STATE_FILE_PATH=".config/sunshine/sunshine_state.json"

if ! [[ "$CONN_STRING" == "" ]];
then
    if ! [[ "$CONN_STRING" == *@* ]];
    then
        echo -e "The first param be a connection string: user@server\n"
        exit 1
    fi

    SS_DATA=$(ssh $CONN_STRING "cat $HOME/$SUNSHINE_STATE_FILE_PATH")
else
    if ! [[ -e "$HOME/$SUNSHINE_STATE_FILE_PATH" ]];
    then
        SS_DATA=""
    else
        SS_DATA=$(cat $HOME/$SUNSHINE_STATE_FILE_PATH)
    fi
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
