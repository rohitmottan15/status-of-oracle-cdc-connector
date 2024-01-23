#!/bin/bash
file_name=connectors_list.txt
ip_address="$(hostname -I |  awk -F " " '{print $1}')"
curl -s -X GET http://"$ip_address":8083/connectors/ | jq | sed '1d;$d' | awk -F "\"" '{print $2}' > "$file_name"
echo -e "\n\e[36m++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\e[0m\n"
cat "$file_name" | while IFS= read -r line; do
check_status="curl -s -X GET http://"$ip_address":8083/connectors/$line/status"
        $check_status | jq > status_$line.txt
        if grep -q "FAILED" status_$line.txt; then
                echo -e "\e[31mFAILED $line\e[0m"
                sed -e 's/\\n/\n/g' -e 's/\\t/\t/g' status_$line.txt > status_$line.v1.txt
                rm status_$line.txt
                echo "$line" >> list_of_failed_connectors.txt
        else
                echo -e "\e[32mRUNNING $line\e[0m"
                rm -rf status_$line.txt
        fi
done
echo -e "\n\e[36m++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\e[0m"
echo -e "\n\t\t\e[33mThanks for using this utility.\e[0m"
rm "$file_name"
