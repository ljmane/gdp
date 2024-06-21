#!/bin/bash

if [ ! "$1" ]; then
        curl -s https://cirt.net/passwords | egrep -o "vendor=[[:alpha:]]+([[:space:]]|\.|-)?[[:alpha:]]*([[:space:]]|\.|-)?[[:alpha:]]*([[:space:]]|\.|-)?[[:alpha:]]*" | cut -d "=" -f 2
        echo "List of available vendors provided above"
        exit
fi

GREPABLE=$(echo "$1" | sed 's/ /\\ /')

VENDOR=$(curl -s https://cirt.net/passwords | egrep -oi "vendor=$GREPABLE" | cut -d '=' -f 2 | head -n 1)

if [ ! "$VENDOR" ]; then
        echo "Vendor $1 not found"
        exit
fi

ENCODED=$(echo "$1" | tr ' ' '+')

TMP_FILE=$(mktemp -u)
curl -s https://cirt.net/passwords?vendor=$ENCODED > $TMP_FILE


xmllint --html $TMP_FILE 2>/dev/null | egrep -A1 '>User ID|>Password|>Version' | cut -d '=' -f 3-4 | cut -d '>' -f 2-3 | tr -d '<b>' | sed 's#/td##' | sed 's#/$##'

rm $TMP_FILE
