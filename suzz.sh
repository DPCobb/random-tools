#!/bin/bash

# suzz: Simple Fuzzer

# TODO: add option for screenshot if URL exists using gowitness

function auto_suzz() {
    printf "Running SUZZ\n"
    if [ $append = true ]; then
        printf "SUZZ Results\n" >> suzz.txt
        printf "SUZZ Results\n" >> suzz_success.txt
    else
        printf "SUZZ Results\n" > suzz.txt
        printf "SUZZ Results\n" > suzz_success.txt
    fi
    echo "Started at " >> suzz.txt
    date >> suzz.txt
    while read line
    do
        url=$(echo $domain | sed s/suzz/$line/g)
        if [ -z "$url" ]; then
            continue
        fi
        printf "\n\nChecking URL: $url\n"
        printf "\n\n----- $url -----\n" >> suzz.txt
        res=$(curl -s --head $url)
        if [ -z "$res" ]; then
            printf "No Results!\n" >> suzz.txt
        else
            printf "$res" >> suzz.txt
            printf "$url\n" >> suzz_success.txt
        fi

        sleep $delay
    done < $wordfile

    printf "\nCompleted at " >> suzz.txt
    date >> suzz.txt

    if [ $print_result = true ]; then
        printf "Printing results...\n\n\n"
        cat suzz.txt
    else 
        printf "Suzz finished, check suzz.txt for results\n"
    fi
}

# Manually enter and process target URL's until quit is entered
function manual_suzz() {
    url_base="blank"
    append=true

    while [ $url_base != 'quit' ]
    do
        printf "Enter URL or quit to exit\n"
        read url_base
        if [ $url_base != 'quit' ]; then
            domain=$url_base
            auto_suzz
        fi
    done    
}

# Global base variables
delay=1.5
print_result=false
mode=auto
append=false
method="GET"

while getopts "f:u:t:X:pm" OPTION; do
    case $OPTION in
        f)
            wordfile=$OPTARG
            ;;
        u)
            domain=$OPTARG
            ;;
        t)
            delay=$OPTARG
            ;;
        p)
            print_result=true
            ;;
        m)
            mode=manual
            ;;
        X)
            method=$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]')
            ;;
    esac
done

# passed ./suzz.sh help
if [ $1 = 'help' ]; then
    printf "

    ssssssssss   uuuuuu    uuuuuu  zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
  ss::::::::::s  u::::u    u::::u  z:::::::::::::::zz:::::::::::::::z
ss:::::::::::::s u::::u    u::::u  z::::::::::::::z z::::::::::::::z 
s::::::ssss:::::su::::u    u::::u  zzzzzzzz::::::z  zzzzzzzz::::::z  
 s:::::s  ssssss u::::u    u::::u        z::::::z         z::::::z   
   s::::::s      u::::u    u::::u       z::::::z         z::::::z    
      s::::::s   u::::u    u::::u      z::::::z         z::::::z     
ssssss   s:::::s u:::::uuuu:::::u     z::::::z         z::::::z      
s:::::ssss::::::su:::::::::::::::uu  z::::::zzzzzzzz  z::::::zzzzzzzz
s::::::::::::::s  u:::::::::::::::u z::::::::::::::z z::::::::::::::z
 s:::::::::::ss    uu::::::::uu:::uz:::::::::::::::zz:::::::::::::::z
  sssssssssss        uuuuuuuu  uuuuzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz

0.1.0

A Simple Web Fuzzer
dc

Replaces any instance of suzz with an entry from the passed word list file

Usage:

./suzz.sh -u [DOMAIN/URL] -f [WORDLIST] -t [TIME DELAY]

EXAMPLE:
./suzz.sh -u https://suzz.example.com -f subdomains.txt -t 2.5

OPTIONAL:
-p Prints results on screen results are also saved to suzz.txt
-m Switches mode to manual domain input mode (if using -m then -u can be omitted)

INFO:
Time delay is seconds between requests
"
    exit
fi

# TODO: check if POST request
if [ $mode = 'auto' ]; then
    auto_suzz
else 
    manual_suzz
fi