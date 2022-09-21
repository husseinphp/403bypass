#!/bin/sh
#install subfinder
docker pull projectdiscovery/subfinder


#alias subfinder
alias subfinder='docker run -it --rm -w /data -v $(pwd):/data projectdiscovery/subfinder'


#install httpx
docker pull projectdiscovery/httpx


#alias httpx
alias httpx='docker run -it --rm -w /data -v $(pwd):/data projectdiscovery/httpx'

#install httpx
docker pull trickest/ffuf

#alias ffuf
alias ffuf='docker run -it --rm -w /data -v $(pwd):/data trickest/ffuf'


echo "subfinder & httpx  & ffuf successfully installs "

echo " ###################################################################" 

echo "403_url_payloads.txtsuccessfully installs "
echo " ###################################################################" 

curl -LO https://raw.githubusercontent.com/aufzayed/bugbounty/main/403-bypass/403_url_payloads.txt

echo "403_url_payloads.txtsuccessfully installs "


subfinder -d $1 -o $1AllSubDomain

echo "AllSubDomain"

echo "cat $1AllSubDomain | wc "

echo " ###################################################################" 

httpx -list $1AllSubDomain -o $1LiveSubDomian 

echo "LiveSubDomian"

echo "cat $1LiveSubDomian  | wc "

echo " ###################################################################" 


echo "Delete https&http "
cat $1LiveSubDomian | sed -e 's/^http:\/\///g' -e 's/^https:\/\///g' | tee $1LiveSubDomianWithouthttps

echo " ###################################################################" 


echo "run webarchive ...."
while read line; do  curl -s "https://web.archive.org/cdx/search/cdx?url=*.$line&output=text&fl=original&collapse=urlkey" ; done < $1LiveSubDomianWithouthttps | tee $1LiveSubDomianwaybackurls


echo " delete jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js .."

echo " ###################################################################" 
sleep 1
cat $1LiveSubDomianwaybackurls | egrep -v ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js)" >> $1LiveSubDomianwaybackurlspure

echo " ###################################################################" 

echo " Live SubdomianPure ..."
echo " ###################################################################" 

echo " cat $1LiveSubDomianwaybackurlspure | wc "
echo " ###################################################################" 
sleep 1
echo " get Only 403 urls"
echo " ###################################################################" 
httpx -list $1LiveSubDomianwaybackurlspure -mc 403 | tee $1403LiveSubDomianwaybackurls

echo " 403 urls .."

echo "cat $1403LiveSubDomianwaybackurls | wc "
echo " ###################################################################" 

echo " Run FuFF To Bypass 403 .. "
alias ffuf='docker run -it --rm -w /data -v $(pwd):/data trickest/ffuf'
sleep 1
ffuf -w 403_url_payloads.txt:FUZZ -w $1403LiveSubDomianwaybackurls:urls   -u urls/FUZZ  -t 15 -fc 403,401,400


# while read line; do  ffuf -w 403_url_payloads.txt:FUZZ -u $line/FUZZ  -fc 403,401,400 ; done < $1403LiveSubDomianwaybackurls

echo " ###################################################################" 
echo " Done . . ..   "
