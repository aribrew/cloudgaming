#!/bin/bash

# This script is meant to be executed via Sunshine.
#
# Create a new app entry with your desired name, and use
# bash run_moonlight_cmdline.sh as the command (include the full path).
#
# Then, edit the cloud_play.sh client script with the required data
# and use it to launch the desired app in the server with the required
# parameters.
#
# For security reasons, no command line starting with 'sudo' or 'su'
# will be accepted.
#

log()
{
	MESSAGE="$1"

	if ! [[ "$MESSAGE" == "" ]];
	then
        echo -e "${MESSAGE}\n" >> $LOGFILE
	fi
}


MOONLIGHT_CMDLINE="$HOME/tmp/moonlight_cmdline"
export LOGFILE="/tmp/moonlight_cmdline.log"


if ! [[ -v DISPLAY ]];
then
    export DISPLAY=:0
fi


if [[ -f "$LOGFILE" ]];
then
    rm "$LOGFILE"
fi


if [[ -f "$MOONLIGHT_CMDLINE/cmdline" ]];
then
    CMDLINE=$(cat "$MOONLIGHT_CMDLINE/cmdline")

    if ! [[ "$CMDLINE" == "" ]];
    then
        # Process the command line to get the command
        # executable and the arguments.
        #
        # Also, clean the argument list of trailing spaces
        # while keeping quotes untouched.

        CMD=$(echo "$CMDLINE" | cut -d ' ' -f 1)

        ARGS=$(echo "$CMDLINE" | awk '{$1=""; print $0}')
        ARGS=$(echo "$ARGS" | awk '{$1=$1; print}')

        if [[ "$CMD" == "su" ]] || [[ "$CMD" == "sudo" ]];
        then
            log "No 'su' or 'sudo' cmdlines are allowed."
            exit 1
        fi

        MESSAGE="Executing $CMD"

        if ! [[ "$ARGS" == "" ]];
        then
            MESSAGE+=" with args: $ARGS"
        fi

        MESSAGE+=" ...\n"

        log "$MESSAGE"


        if [[ -f "$MOONLIGHT_CMDLINE/env" ]];
        then
            source "$MOONLIGHT_CMDLINE/env"
        fi

        $CMDLINE

        if [[ -f "$MOONLIGHT_CMDLINE/env" ]];
        then
            rm "$MOONLIGHT_CMDLINE/env"
        fi

        rm "$MOONLIGHT_CMDLINE/cmdline"
    fi
else
    log "No cmdline to execute found.\n"
fi
