#!/bin/bash

# Usage
if [ "$#" -ne 1 ]; then
    echo -e "Usage: ./md-link-checker.sh <file.md>\n"
    exit 0
fi

printf "\nChecking links in $1\n"
links=$(grep -ioP "\(http?s://[^\s:,]+\)" "$1" | sed 's/(//g; s/)//g')

# Exit if no links were found in markdown file
if [ -z "$links" ]; then
    echo "No links found in $1"
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

# Headers
echo -e "Status\t| Link"
echo -e "---------------"

# Check each link
set -a
function get_status_code() {
    status_code=$(curl -sw "%{http_code}" -o /dev/null "$link")
    status_code_category="${status_code:0:1}"
}

i=0;
info_cnt=0; success_cnt=0; redirect_cnt=0; client_err_cnt=0; server_err_cnt=0; unknown_cnt=0;
while read -r link; do
    {
        status_code=$(curl -Lsw "%{http_code}" -o /dev/null "$link")
        status_code_category="${status_code:0:1}"
        if [ "$status_code_category" -eq "1" ]; then
            echo -e "$status_code\t| $bldwhite$link$txtrst"
            info_cnt=$((info_cnt+1))
        elif [ "$status_code_category" -eq "2" ]; then
            echo -e "$status_code\t| $bldgreen$link$txtrst"
            success_cnt=$((success_cnt+1))
        elif [ "$status_code_category" -eq "3" ]; then
            echo -e "$status_code\t| $bldyellow$link$txtrst"
            redirect_cnt=$((redirect_cnt+1))
        elif [ "$status_code_category" -eq "4" ]; then
            echo -e "$status_code\t| $bldmagenta$link$txtrst"
            client_err_cnt=$((client_err_cnt+1))
        elif [ "$status_code_category" -eq "5" ]; then
            echo -e "$status_code\t| $bldred$link$txtrst"
            server_err_cnt=$((server_err_cnt+1))
        else
            echo -e "$status_code\t| $bldcyan$link$txtrst"
            unknown_cnt=$((unkwnown_cnt+1))
        fi
    }& # Fork each execution to skip waiting for curl on each iteration
    i=$((i+1))
done <<< "$links"

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
printf "${bldcyan}UNKNOWN\t| ${unknown_cnt}${txtrst} => Curl probably recieved 000 and may have timed out\n"
printf "\n"
