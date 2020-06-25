#!/bin/sh

wget http://dnsmasq-server/youtube.txt -O youtube-dnsmasq.txt
wget http://openwrt-router/youtube.txt -O youtube-openwrt.txt
cat youtube-dnsmasq.txt >> youtube.txt
cat youtube-openwrt.txt >> youtube.txt
if [[ -e links.txt ]]; then
  for link in `cat links.txt | grep termbin`; do
    wget $link -O youtube-link.txt
    cat youtube-link.txt >> youtube.txt
    rm youtube-link.txt
  done
fi
echo > links.txt
wget https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master/black.list -O youTube_ads_4_pi.txt
cat youTube_ads_4_pi.txt >> youtube.txt
rm youTube_ads_4_pi.txt
wget https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master/youtubelist.txt -O youTube_ads_4_pi.txt
cat youTube_ads_4_pi.txt >> youtube.txt
rm youTube_ads_4_pi.txt
sed -i 's/sn--/sn-/' youtube.txt
for i in $(cat youtube.txt | cut -d"." -f1 | awk -F"sn-" '{print $2}'); do
  for j in $(seq 20); do
    echo "r$j---sn-$i.googlevideo.com" >> youtube.txt
  done
done
#sed -ni '/r[0-9][0-9]\?[0-9]\?---sn-.........\?.\?.g/p' youtube.txt
cat youtube.txt | egrep -v "^r[0-9][0-9]?.s" > temp.txt
mv temp.txt youtube.txt
sed -i 's/------/---/' youtube.txt
sed -i 's/-----/---/' youtube.txt
sed -i '/blocked/d' youtube.txt
sort --output youtube.txt youtube.txt
#gawk -i inplace '!a[$0]++' youtube.txt
rm youtube-dnsmasq.txt
rm youtube-openwrt.txt
perl -i -ne 'print if ! $x{$_}++' youtube.txt
git commit -am "Automatic commit update"
git push --all origin
