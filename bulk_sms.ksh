#!/usr/bin/env bash
#
# Script Name : bulk_sms.sh
# Author : Shubham Srivastava
# Date : 26/03/2022
# Description : The following script uses telnyx API v2 to send bulk sms

today_date=$(date)
echo "Today's date is $today_date"

filetime=`date +%Y%m%d%H%M%S`

location=/Users/shubham/Documents/Telnyx_Bulk_SMS                               ##path where you want to store this project on youe workstation.

exec 1>$location/sms_output_$filetime.log                                       ## Creates a log file for the entire script & captuing the endpoint respionse
input="$location/number.txt"                                                    ## input refers to the destination number list file.
message_file="$location/sms_body.txt"                                           ## message_file is the body of sms that is being sent out
message=`cat $message_file`                                                     ## message is a variable which stores the SMS body
from="+111111111"                                                               ## the from number
YOUR_API_KEY="KEY017xxxxxxxxxxxxxxxo0WxxxxxxxxxxxEjCAbxxxxxxxxxxxxxxxfk"        ## API key generated on telnyx portal - https://portal.telnyx.com/#/app/api-keys

# checking if the number file is empty

if [ -s "$input" ];                                                             ## -s checks if the file is empty or not
    then
      echo "Number file looks good";
    else
      echo "Number file is empty"
    exit 0
    sleep 5
fi

# checking if the message_file file is empty

if [ -s "$message_file" ];
    then
      echo "message file looks good";
    else
      echo "message file is empty"
    exit 1
    sleep 5
fi



## execution of bulk sms loop ##

while IFS= read -r line                                                         ## while loop is evecuted for each line in the input file
do
echo "$line"
echo "creating script for $line"

############ creating a temp wrapper script based on the number #############

cat>sub_script.ksh<<EOF1
#!/usr/bin/env bash


  curl -X POST \
    --header "Content-Type: application/json" \
    --header "Accept: application/json" \
    --header "Authorization: Bearer $YOUR_API_KEY" \
    --data '{
      "from": "$from",
      "to": "$line",
      "text": "$message"
    }' \
    https://api.telnyx.com/v2/messages


EOF1

chmod +x sub_script.ksh                                                          ## setting execution permission to the wrapper script
echo "running script for $line"

echo ""

./sub_script.ksh                                                                ## running the wrapper script with $line input

sleep 2                                                                         ## Waiting for 2 seconds for the next loop execution (can be changed to 1 for fast sms POST request)

done < "$input"                                                                 ## Input file is being given for the while loop


echo ""
echo "script is executed, please check the log file"
echo ""

sleep 3

echo "removing files"
rm -f sub_script.ksh                                                            ## removing the wrapper script created while executing the main script

exit 2
