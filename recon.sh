#! /bin/bash

function nmap_scan() {
    printf "\n\n----- nmap scan-----\n"
    printf "Enter IP\n"
    read ip
    printf "\nReport For: $ip\n"

    nmap $ip | tail -n +5 | head -n -3
    printf "\n\n"
    menu
}

function nslookup_scan() {
    printf "\n\n----- nslookup -----\n"
    printf "\nEnter Host:\n"
    read host

    res=$(nslookup $host)

    printf "nslookup result for $host:\n"
    
    printf "$res\n\n"
}

function whatweb_scan() {
    printf "\n\n----- whatweb scan -----\n"
    printf "\nEnter Host:\n"
    read host
    res=$(whatweb $host -v)
    printf "whatweb result for $host:\n"
    printf "$res\n\n"
    menu
}

function menu() {
    selection='blank'
    while [ $selection != 'quit' ]
    do
        printf 'Select an option below:'
        printf "
[1] Basic nmap scan of target
[2] whatweb scan
[3] nslookup (get IP)
[q] Quit

Enter your choice...\n"

        read choice

        if [ $choice = 'q' ]; then
            selection=quit
        fi

        if [ $selection != 'quit' ]; then
            case $choice in
                1)
                    nmap_scan
                    ;;
                2)
                    whatweb_scan
                    ;;
                3)
                    nslookup_scan
                    ;;
            esac
        fi

    done
}

menu