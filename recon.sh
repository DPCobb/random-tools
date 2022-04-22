#! /bin/bash

reverse_who=false

function gobuster_tool() {
    printf "\n\n----- gobuster results -----\n"
    printf "Enter Host\n"
    read host
    printf "Enter word list path\n"
    read wordlist
    res=$(gobuster -u $host -w $wordlist) 
    printf "$res\n\n"
    res=$(gobuster -m dns -u $host -w $wordlist) 
    printf "$res\n\n"
}

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

function whois_rep() {
    if [ $reverse_who != true ]; then
        printf "\n\n----- whois -----\n"
        printf "\nEnter IP:\n"
        read ip
        res=$(whois $ip)
        printf "whois result for $ip:\n"
        printf "$res\n\n"
        menu
    else
        printf "\n\n----- reverse whois -----\n"
        printf "\nEnter IP:\n"
        read ip
        res=$(whois -h whois.cymru.com $ip)
        printf "reverse whois result for $ip:\n"
        printf "$res\n\n"
        menu
    fi
}

function cert_check() {
    printf "\n\n----- cert check -----\n"
    printf "\nEnter Host:\n"
    read host
    res=$(curl "https://crt.sh/?q=$host&output=json")
    printf "cert check result for $host:\n"
    echo $res > temp.txt
    jq '.' temp.txt > cert.json
    rm temp.txt
    printf "Results sent to cert.json\n\n"
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
[4] whois
[5] Reverse whois
[6] Get certificate information
[7] Run gobuster
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
                4)
                    whois_rep
                    ;;
                5)
                    reverse_who=true
                    whois_rep
                    ;;
                6)
                    cert_check
                    ;;
                7)
                    gobuster_tool
                    ;;
            esac
        fi

    done
}

menu