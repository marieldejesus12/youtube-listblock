#!/usr/bin/env ash
#
# ------------------------------------------------------------------------------
#
# YouTube BlockList Adguard Home collect Script
#
# AUTHOR: Mariel de Jesus ™ <marieldejesus12@gmail.com>
# MAINTAINERS:
#
# ------------------------------------------------------------------------------
#
# DESCRIPTION:
#
# This script is able to obtain urls for youtube video advertisements through
# the OpenWRT log, generate a local block list for immediate effect and
# send a copy of that same list to the script author via Telegram (I am
# open to suggestions regarding to that, I couldn't think of a better idea yet).
#
# ------------------------------------------------------------------------------
#
# # LICENSE:
# This program is Free Software, you can redistribute and / or modify it under
# the terms of the GNU General Public License Version 3 published by Free
# Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; Without even implying guarantees of MERCHANTABILITY or
# ADAPTATION TO AN PRIVATE PURPOSE. See the GNU General Public License (GPL)
# for more details (https://www.gnu.org/licenses/gpl-3.0.html).
#
# ------------------------------------------------------------------------------
#
# DEPENDENCIES:
#
# perl curl grep
#
# ------------------------------------------------------------------------------
VERSION=40
OVERLAY=$(df | grep '/dev/sd' | awk '{print $2,$6}' | sort -nr | sed -n '1p' | awk '{print $2}')
if [[ "$OVERLAY" = "" ]]; then
  SYSTEMLOG="/tmp/system.log"
else
  SYSTEMLOG="/$OVERLAY/system.log"
fi
CRONTAB="/etc/crontabs/root"
SCRIPT="$(basename $0)"

function echov(){
  echo -e "\033[01;32m$1...\033[00;37m"
}

#Verify if is root
if [[ "$(id -u)" != "0" ]]; then
  echov "This script requires root or sudo"
  echo ""
  echov "Exiting"
  exit 1
fi

function install() {
  echov "Checking dependencies"
  #Install dependencies
  PKG=""
  if [[ ! -e "/usr/bin/perl" ]]; then
    PKG="$PKG perl"
  fi
  if [[ ! -e "/usr/bin/curl" ]]; then
    PKG="$PKG curl"
  fi
  if [[ ! -e "/usr/bin/grep" ]]; then
    PKG="$PKG grep"
  fi
  if [[ ! -z "$PKG" ]]; then
    echov "Installing dependencies"
    opkg update > /dev/null 2>&1
    opkg install $PKG > /dev/null 2>&1
  fi

  #Enable log dns
  uci set dhcp.cfg01411c.logqueries='1'
  uci commit dhcp

  move_rename
  echov "Installation complete"
}

function upgrade() {
  #Check remote version
  echov "Checking updates"
  REMOTE=$(curl https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/$SCRIPT | grep 'VERSION=' | sed 's/^.*=//') > /dev/null 2>&1
  #Update if available update
  if [[ $VERSION -lt $REMOTE ]]; then
    echov "Updates found, updating"
    curl https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/$SCRIPT -o $0
    echov "Upgrade $0 complete, checking installation"
    $0 install
  else
    echov "No updates required"
  fi
}

function move_rename() {
  #Configure log system
  echov "Configuring OpenWRT logs"
  if [[ "$OVERLAY" = "" ]]; then
    uci set system.cfg01e48a.conloglevel='5'
    uci set system.cfg01e48a.cronloglevel='8'
    uci set system.cfg01e48a.log_file="$SYSTEMLOG"
    uci set system.cfg01e48a.log_size='102400'
  else
    uci set system.cfg01e48a.conloglevel='8'
    uci set system.cfg01e48a.cronloglevel='5'
    uci set system.cfg01e48a.log_file="$SYSTEMLOG"
    uci set system.cfg01e48a.log_size='1024000'
  fi
  uci commit system
  #Move script to /usr/bin
  if [[ "$0" != "/usr/bin/openwrt_collect.sh"  ]]; then
    echov "Moving script to /usr/bin"
    mv $0 /usr/bin/openwrt_collect.sh
    chmod +x /usr/bin/openwrt_collect.sh
    SCRIPT="openwrt_collect.sh"
  fi
  #Configure cron
  if [[ "$(grep $SCRIPT $CRONTAB)" != "" ]]; then
    TESTCRON=$(grep "15 02 * * * /usr/bin/$SCRIPT upgrade" $CRONTAB)
    if [[ "$TESTCRON" = "" ]]; then
      echov "Adjusting crontabs"
      grep -v  $SCRIPT $CRONTAB > /tmp/crontabs
      mv /tmp/crontabs $CRONTAB
      echo "15 02 * * * /usr/bin/$SCRIPT upgrade" >> $CRONTAB
      echo "15 03 * * * /usr/bin/$SCRIPT update" >> $CRONTAB
      /etc/init.d/cron restart
    fi
  else
    echov "Adjusting crontabs"
    echo "15 02 * * * /usr/bin/$SCRIPT upgrade" >> $CRONTAB
    echo "15 03 * * * /usr/bin/$SCRIPT update" >> $CRONTAB
    /etc/init.d/cron restart
  fi
}

function update() {
  echov "Updating lists"
  FILETMP=/tmp/temp.txt
  LOCALLIST=/www/youtube.txt
  URLLIST=/tmp/url_list.txt

  # Fetch the list of domains, remove the ip's and save them
  curl 'https://api.hackertarget.com/hostsearch/?q=googlevideo.com' \
  | awk -F, 'NR>1{print $1}' \
  | grep -vE "redirector|manifest" > $FILETMP

  # Scan log file for previously accessed domains
  for ARCHIVELOG in $(ls $SYSTEMLOG* > /dev/null 2>&1); do
    grep r*.googlevideo.com $SYSTEMLOG \
    | awk '{print $6}' \
    | grep -v '^googlevideo.com\|redirector\|manifest' \
    | sort | uniq >> $FILETMP
  done

  # Replace r*.sn*.googlevideo.com URLs to r*---sn-*.googlevideo.com
  # and add those to the list too
  cat $FILETMP | sed -i $FILETMP -re 's/(^r[[:digit:]]+)(.)/\1---/' >> $FILETMP

  #delete duplicates
  perl -i -ne 'print if ! $x{$_}++' $FILETMP

  #copy file to blacklist
  cat $FILETMP | grep -v "cxae" | grep -v "blocked" >> $LOCALLIST

  #Remove excess of hifens
  sed -i 's/------/---/' $LOCALLIST
  sed -i 's/-----/---/' $LOCALLIST

  #delete duplicates
  perl -i -ne 'print if ! $x{$_}++' $LOCALLIST

  #Sort list
  cat $LOCALLIST | sort > /tmp/sort_list.txt
  mv /tmp/sort_list.txt $LOCALLIST

  #removes the temporarys files on the raspberry pi
  rm $FILETMP
  if [[ "$OVERLAY" = "" ]]; then
    echo -n > $SYSTEMLOG
    for ARCHIVELOG in `ls $SYSTEMLOG*`; do
      if [[ $ARCHIVELOG != $SYSTEMLOG ]]; then
        rm $ARCHIVELOG
      fi
    done
  fi

  #Up lists to https://t.me/marieldejesus12
  cat $LOCALLIST | nc termbin.com 9999 > $URLLIST
  url_list="`cat $URLLIST | sed -n '1p'`"
  curl https://api.telegram.org/bot1116754012:AAGanRUuS7WpGPJmN7YBDMbme8n-e-ChqGk/sendMessage\?chat_id\=128586066\&text\=$url_list
  rm $URLLIST

  echov "Update lists complete"
  exit
}

case $1 in
  install )
    install;;
  upgrade )
    upgrade;;
  update )
    update;;
  * )
    echov "Usage $SCRIPT [install|update|upgrade]";
    echo "";
    echov "Invalid command, try again";
    exit 1;;
esac
