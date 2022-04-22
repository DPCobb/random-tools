#!/bin/bash

# suzz: Simple Fuzzer

function suzz_post() {
    printf "\nEnter POST options:\n"
    read post_options
    printf "\nEnter any custom headers:\n"
    read cust_headers

    while read line
    do

        url=$(echo $domain | sed s/suzz/$line/g)

        if [[ ! -z $post_options ]]; then
            post_options=$(echo $post_options | sed s/suzz/$line/g)
        fi

        if [[ ! -z $cust_headers ]]; then
            cust_headers=$(echo $cust_headers | sed s/suzz/$line/g)
        fi

        if [ $full_result = true ]; then

            res=$(curl -X POST -H "$cust_headers" $post_options $url)

            printf "$url: Result: $res\nHEADERS:$cust_headers\nOPTIONS:$post_options\n\n"
            printf "$url: Result: $res\nHEADERS:$cust_headers\nOPTIONS:$post_options\n\n" >> suzz.txt

        else
            res=$(curl -s  -o /dev/null -w '%{http_code}\n' -X POST -H "$cust_headers" $post_options $url)

            printf "$url: HTTP Status $res\nHEADERS:$cust_headers\nOPTIONS:$post_options\n\n"
            printf "$url: HTTP Status $res\nHEADERS:$cust_headers\nOPTIONS:$post_options\n\n" >> suzz.txt
        fi

    done < $wordfile
}

function auto_suzz() {
    printf "Running SUZZ\n"
    if [ $method = 'post' ]; then
        suzz_post
        exit 1
    fi
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
        printf "\n\n----- $url -----\n" >> suzz.txt
        res=$(curl -s --head $url)
        if [ -z "$res" ]; then
            printf "$url: No Response\n"
            printf "No Results!\n" >> suzz.txt
        else
            printf "$res" >> suzz.txt
            printf "$url\n" >> suzz_success.txt
            code=$(echo $res | awk -F ' ' '{print $2}')
            printf "\e[0;32m$url: HTTP Code: $code\e[0m\n"
        fi

        sleep $delay
    done < $wordfile

    printf "\nCompleted at " >> suzz.txt
    date >> suzz.txt

    if [ $print_result = true ]; then
        printf "Printing results...\n\n\n"
        cat suzz.txt
    else 
        printf "\nSuzz finished, check suzz.txt for results\n"
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
mode='auto'
append=false
method='get'
full_result=false

while getopts "f:u:t:X:pmr" OPTION; do
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
            mode='manual'
            ;;
        X)
            method='post'
            ;;
        r)
            full_result=true
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
-X Switches to POST request
-r Used with -X to print full response of POST

INFO:
Time delay is seconds between requests

POST Requests:
Script will ask for POST options enter something like:
-d \"name=dan&age=999\"
Script will ask for your headers as well:
Content-Type:application/json

URL, POST options, and headers are searched for suzz and replaced with word file entry.


"
    exit
fi

if [ $mode = 'auto' ]; then
    auto_suzz
else 
    manual_suzz
fi