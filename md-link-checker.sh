#!/bin/bash

# Usage
if [ "$#" -ne 1 ]; then
    echo -e "Usage: ./md-link-checker.sh <file.md>\n"
    exit 0
fi

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
txtrst=$(tput sgr0)

# Headers
echo -e "Status\t| Link"
echo -e "---------------"

# Check each link
set -a
i=0; good_count=0; bad_count=0; redirect_count=0

function get_status_code() {
    status_code=$(curl -sw "%{http_code}" -o /dev/null "$link")
    status_code_category="${status_code:0:1}"
}

while read -r link; do
    {
        status_code=$(curl -Lsw "%{http_code}" -o /dev/null "$link")
        status_code_category="${status_code:0:1}"
        if [ "$status_code_category" -eq "1" ] || [ "$status_code_category" -eq "2" ]; then
            echo -e "$status_code\t| $bldgreen$link$txtrst"
            good_count=$((good_count+1))
        elif [ "$status_code_category" -eq "3" ]; then
            echo -e "$status_code\t| $bldyellow$link$txtrst"
            redirect_count=$((good_count+1))
        elif [ "$status_code_category" -eq "4" ] || [ "$status_code_category" -eq "5" ]; then
            echo -e "$status_code\t| $bldred$link$txtrst"
            bad_count=$((bad_count+1))
        else
            echo -e "$status_code\t| $link"
        fi
    }& # Fork each execution to skip waiting for curl on each iteration
    i=$((i+1))
done <<< "$links"

wait
echo -e "\nChecked $i links in $1\n"
