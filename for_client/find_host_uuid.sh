#!/bin/bash

CONN_STRING="$1"


if ! [[ "$CONN_STRING" == "" ]];
then
    if ! [[ "$CONN_STRING" == *@* ]];
    then
        echo -e "The first param be a connection string: user@server\n"
        exit 1
    fi

    SUNSHINE_STATE_FILE="~/.config/sunshine/sunshine_state.json"

    SS_DATA=$(ssh $CONN_STRING "source .environment; cat $SUNSHINE_STATE_FILE")

    if ! [[ "$SS_DATA" == "" ]];
    then
        UUID=$(echo "$SS_DATA" | grep "uniqueid")
        UUID=$(echo "$UUID" | cut -d ':' -f 2 | cut -d ',' -f 1 | xargs)

        if ! [[ $(echo "$UUID" | cut -d '-' -f 5) == "" ]];
        then
            echo "$UUID"
        fi
    fi
fi
