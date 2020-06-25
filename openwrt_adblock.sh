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
# This script gets the list of youtube video advertising urls from the local
# YouTube list ListBlock on the WEB and inserts it in the Adblock-OpenWRT
# blacklist.
#
# ------------------------------------------------------------------------------
#
# LICENSE:
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
# ------------------------------------------------- -----------------------------
VERSION=33
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
  if [[ ! -e "/usr/bin/perl" ]]; then PKG="$PKG perl"
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
  #Move script to /usr/bin
  if [[ "$0" != "/usr/bin/openwrt_adblock.sh"  ]]; then
    echov "Moving script to /usr/bin"
    mv $0 /usr/bin/openwrt_adblock.sh
    chmod +x /usr/bin/openwrt_adblock.sh
    SCRIPT="openwrt_adblock.sh"
  fi
  #Configure cron
  if [[ "$(grep $SCRIPT $CRONTAB)" != "" ]]; then
    TESTCRON=$(grep "30 02 * * * /usr/bin/$SCRIPT upgrade" $CRONTAB)
    if [[ "$TESTCRON" = "" ]]; then
      echov "Adjusting crontabs"
      grep -v  $SCRIPT $CRONTAB > /tmp/crontabs
      mv /tmp/crontabs $CRONTAB
      echo "30 02 * * * /usr/bin/$SCRIPT upgrade" >> $CRONTAB
      echo "30 03 * * * /usr/bin/$SCRIPT update" >> $CRONTAB
      /etc/init.d/cron restart
    fi
  else
    echov "Adjusting crontabs"
    echo "30 02 * * * /usr/bin/$SCRIPT upgrade" >> $CRONTAB
    echo "30 03 * * * /usr/bin/$SCRIPT update" >> $CRONTAB
    /etc/init.d/cron restart
  fi
}

function update() {
  echov "Updating lists"
  ADBLOCK=/etc/adblock/adblock.blacklist
  LOCALLIST=/www/youtube.txt
  FILETMP=/tmp/youtube.txt

  #copy files to blacklist
  if [[ -e $LOCALLIST ]]; then
    cat $LOCALLIST >>  $ADBLOCK
  fi

  curl https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/youtube.txt -o $FILETMP
  cat $FILETMP >>  $ADBLOCK
  rm $FILETMP

  #delete duplicates
  perl -i -ne 'print if ! $x{$_}++' $ADBLOCK

  #Sort list
  cat $ADBLOCK | sort > /tmp/sort_list.txt
  mv /tmp/sort_list.txt $ADBLOCK

  #Update ADBLOCK
  /etc/init.d/adblock reload

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
