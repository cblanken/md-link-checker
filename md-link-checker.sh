#!/bin/bash
set -a

# TODO: handle Ctrl+C signal
# TODO: error handling
# TODO: allow entry of directory and automatic markdown file search

file="$1"
mode="$2"

# Usage
if [ "$#" -eq 2 ] && [ "$mode" == "txt" ]; then
    links=$(grep -iP "http?s://" "$file")
elif [ "$#" -eq 1 ] || [ "$mode" == "md" ]; then
    links=$(grep -ioP "\(https?://[^\s:,]+\)" "$file" | sed 's/(//g; s/)//g')
else
    echo -e "Usage: ./md-link-checker.sh <file.md> [mode]"
    echo -e "Modes:"
    echo -e "  - md [default]: parse links from Markdown file"
    echo -e "  - txt: parse links from text file (one link per line)"
    exit 0
fi

# Exit if no links were found in file
if [ -z "$links" ]; then
    echo "No links found in $file"
    exit 0
fi

# Output colors
txtbld=$(tput bold)
bldred=${txtbld}$(tput setaf 1)
bldgreen=${txtbld}$(tput setaf 2)
bldyellow=${txtbld}$(tput setaf 3)
bldblue=${txtbld}$(tput setaf 4)
bldmagenta=${txtbld}$(tput setaf 5)
bldcyan=${txtbld}$(tput setaf 6)
bldwhite=${txtbld}$(tput setaf 7)
txtrst=$(tput sgr0)

printf "\nChecking links in $file...\n"
echo -e "---------------"
echo -e "Status\t| Link"
echo -e "---------------"

i=0;
info_cnt=0; success_cnt=0; redirect_cnt=0; client_err_cnt=0; server_err_cnt=0; unknown_cnt=0;
while read -r link; do
    i=$((i+1))
    {
        status_code=$(curl -H "Accept-Charset: utf-8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0" -Lsw "%{http_code}" -o /dev/null "$link")
        status_code_category="${status_code:0:1}"
        if [ "$status_code_category" -eq "1" ]; then
            echo -e "$status_code\t| $bldwhite$link$txtrst"
            exit 1
        elif [ "$status_code_category" -eq "2" ]; then
            echo -e "$status_code\t| $bldgreen$link$txtrst"
            exit 2
        elif [ "$status_code_category" -eq "3" ]; then
            echo -e "$status_code\t| $bldyellow$link$txtrst"
            exit 3
        elif [ "$status_code_category" -eq "4" ]; then
            echo -e "$status_code\t| $bldmagenta$link$txtrst"
            exit 4
        elif [ "$status_code_category" -eq "5" ]; then
            echo -e "$status_code\t| $bldred$link$txtrst"
            exit 5
        else
            echo -e "$status_code\t| $bldcyan$link$txtrst"
            exit 6
        fi
    }& # Fork each execution to skip waiting for curl on each iteration
    pids[${i}]=$! # keep array of fork PIDs
done <<< "$links"

# Wait for each fork to complete and check HTTP status
for pid in ${pids[@]}; do
    wait "$pid"
    ret=$?
    if [ "$ret" == 1 ]; then
        info_cnt=$((info_cnt+1))
    elif [ "$ret" == 2 ]; then
        success_cnt=$((success_cnt+1))
    elif [ "$ret" == 3 ]; then
        redirect_cnt=$((redirect_cnt+1))
    elif [ "$ret" == 4 ]; then
        client_err_cnt=$((client_err_cnt+1))
    elif [ "$ret" == 5 ]; then
        server_err_cnt=$((server_err_cnt+1))
        echo "SUCCESS: $success_cnt"
    elif [ "$ret" == 6 ]; then
        unknown_cnt=$((unknown_cnt+1))
    fi
done

wait # wait for all forks to complete

printf "\n"
echo   "---------------"
printf "Status\t| Count\n"
echo   "---------------"
printf "${bldwhite}1xx\t| ${txtrst}$info_cnt\n"
printf "${bldgreen}2xx\t| ${success_cnt}${txtrst}\n"
printf "${bldyellow}3xx\t| ${redirect_cnt}${txtrst}\n"
printf "${bldmagenta}4xx\t| ${client_err_cnt}${txtrst}\n"
printf "${bldred}5xx\t| ${server_err_cnt}${txtrst}\n"
printf "${bldcyan}UNKNOWN\t| ${unknown_cnt}${txtrst} => Curl probably received 000 and may have timed out\n"
printf "\n"
