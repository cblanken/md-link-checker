#!/bin/bash

links=$(grep -ioP "\(http?s://[^\s:,]+\)" "$1" | sed 's/(//g; s/)//g')

# Output colors
txtbnd=$(tput bold)
bldred=${txtbld}$(tput setaf 1)
bldgreen=${txtbld}$(tput setaf 2)
bldyellow=${txtbld}$(tput setaf 3)
txtrst=$(tput sgr0)

# Headers
echo -e "Status\t| Link"
echo -e "---------------"

i=0; good_count=0; bad_count=0; redirect_count=0
while read link; do
    status_code=$(curl -sw "%{http_code}" -o /dev/null "$link")
    status_code_category="${status_code:0:1}"
    if [ "$status_code_category" -eq "1" ] || [ "$status_code_category" -eq "2" ]; then
        echo -e "$status_code\t| $bldgreen$link$txtrst"
        good_count=$((good_count+1))
    elif [ "$status_code_category" -eq "3" ]; then
        echo -e "$status_code\t| $bldyellow$link$txtrst"
        redirect_count=$((good_count+1))
    elif [ "$status_code_category" -eq "4" ] || [ "$status_code_category" -eq "4" ]; then
        echo -e "$status_code\t| $bldred$link$txtrst"
        bad_count=$((bad_count+1))
    else
        echo -e "$status_code\t| $link"
    fi
    i=$((i+1))
done <<< "$links"

echo -e "\nChecked $i links in $1"
echo -e "$bldgreen$good_count$txtrst\tgood links"
echo -e "$bldred$bad_count$txtrst\tbad links"
echo -e "$bldyellow$redirect_count$txtrst\tredirects"

