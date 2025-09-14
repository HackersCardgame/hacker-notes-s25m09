#!/bin/bash

# Script for installing zabbix automatically
#
# ============================================================================
# title          : zabbix.trixie.sh
# description    : 
# author         : Marc jr. landolt 
#                  Twitter: <s>@FailDef</s> @PinkyDef
#                  Telegram: @HackersCardgame / @ NSA _ CIA
#                  Facebook: /marc.landolt.9
#
# version        : 0.2.1
# usage          : zabbix.trixie.sh
#
# documentation  : /usr&share/doc/zabbix-*/README.Debian
#                  https://www.zabbix.om/documentation...
#
# ============================================================================
#

installDate=$(date +%Y-%m-%d.%H.%M.%S)
echo $installDate
figlet $installDate
echo $installDate

#EDITOR=$(which nano)
EDITOR=$(which vim)

red="\e[91m"
yellow="\e[93m"
green="\e[92m"
blue="\e[94m"
default="\e[39m"

#distro=jessie
#distro=stretch
#distro=bullseye
#distro=bookworm
distro=trixie

# Helper Function(s)
# ============================================================================
function showAndRun {

  echo -e "${yellow} ⦾ ${default} $1"
  rm temp*log >/dev/null 2>&1
  $1  >temp.log 2>tempErr.log 
  rc=$?
  #cat temp*log 
  if [[ $rc != 0 ]]      # rc = return code
  then echo -e "${red} 🗷  EE ERROR ${default} $1" | tee -a ${installDate}.log && cat temp*log >> ${installDate}.log 
  else echo -e "${green} 🗹  II ${default} $1" | tee -a ${installDate}.log
fi

}


function test {

echo -e "${red} red ${yellow} yellow ${green} green ${blue} blue ${default} $1 $2 $3 "

}

test test1 simple "color test"


function install {

showAndRun "apt-get -y install $1"

}


function YESNO {

  echo -e -n "${yellow} ⦾ $1${default} [y/N]"
  read -d'' -s -n1 answer
  echo
  if [ $answer = 'y' ] || [ $answer = 'Y' ]
  then
    echo -e "${green} YES: ${default} $1" | tee -a ${installDate}.log
    return 0
  else
    echo -e "${yellow} NO: ${default} $1" | tee -a ${installDate}.log
    return 1
  fi

}


if YESNO "fix apt-get and dpkg ?" 
then
  echo fixing apt and dpkg and updating
  showAndRun "cat -e /var/lib/dpkg/lock"
  showAndRun "apt --fix-broken install"
  showAndRun "dpkg --configure -a"
  showAndRun "apt-get -y update"
  showAndRun "apt-get -y upgrade"
fi


# installations Schritte :

install snmp
install snmpd
install nmap
install snmp-mibs-downloader   # Requires non-free repository

install zabbix-agent 
install zabbix-agent2
install zabbix-frontend-php
install zabbix-server-pgsql
install zabbix-web-service
install zabbix-cli

install postgresql
install apache2
install php8.4      # will be dfifferent in next version
install libapache2-mod-php
install php
install php-pgsql

cd /home

sudo -u postgres psql -c "\l"   

if YESNO "drop old database completely ?"
then
  sudo -u postgres psql -c "drop database zabbix;"
fi

if YESNO "create and populate zabbix database ?"
then
  sudo -u postgres createuser --pwprompt zabbix
  sudo -u postgres createdb -O zabbix zabbix
  zcat /usr/share/zabbix-server-pgsql/schema.sql.gz | sudo -u postgres psql -d zabbix
  zcat /usr/share/zabbix-server-pgsql/images.sql.gz | sudo -u postgres psql -d zabbix
  zcat /usr/share/zabbix-server-pgsql/data.sql.gz | sudo -u postgres psql -d zabbix
  sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE zabbix TO zabbix;"  # psql -W -U zabbix -h localhost -d zabbix
  sudo -u postgres psql -d zabbix -c "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO zabbix;"
    # ERROR, diesen befehl muss man scheinbar von hand eintragen, fehlerursache noch unklar -- allenfalls braucht es noch das -d zabbix
  sudo -u postgres psql -d zabbix -c "GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO zabbix;"
  sudo -u postgres psql -d zabbix -c "GRANT USAGE ON SCHEMA public TO zabbix;"

fi

sudo -u postgres psql -W -U zabbix -h localhost -d zabbix -c "select * from dbversion;"
sudo -u postgres psql -h localhost -d zabbix -c "\z dbversion"

ln -s /usr/share/zabbix /var/www/html/ 

/usr/sbin/a2enmod php

if YESNO "modify /etc/php/*/apache2/php.ini and edit zabbix config for DB-Password ?"
then
  echo "
    post_max_size = 16M
    max_execution_time = 300
    max_input_time = 300
    " >> /etc/php/8.4/apache2/php.ini

  vim -c "/DBPas" /etc/zabbix/zabbix_server.conf

  systemctl stop zabbix-server apache2
  systemctl start zabbix-server apache2
  systemctl enable zabbix-server apache2

fi

echo postgre should be on port 5432
nmap localhost

psql -W -U zabbix -h localhost -d zabbix


if YESNO "enable write access to /etc/zabbix ?"
then
  chmod o+w /etc/zabbix
  read -p "
  Press [ENTER] after zabbix frontend installation on https://<Server IP</zabbix/"
  chmod o-w /etc/zabbix
fi

if YESNO "print logfile ?"
  then
    cat ${installDate}.log
fi

