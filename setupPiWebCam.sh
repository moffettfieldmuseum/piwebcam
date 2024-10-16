#!/usr/bin/env bash
set -u
set -vx

ARG[1]="piwebcam"
ARG[2]="piwebcam"
argno=0
USERID=pmeigs

BUILDHOST=${ARG[1]}
TARGETHOST=${ARG[2]}

# echo $BUILDHOST $TARGETHOST ${EXHIB}

# TARGETHOST=mfhsm-candy-10.javaxpresso.com

sed -i -e '/|1|/d' ~/.ssh/known_hosts
ssh -t -l ${USERID}  ${TARGETHOST}<<ENDOFDATA
mkdir -p .ssh
mkdir -p .config
touch .config/gnome-initial-setup-done
cat <<EOF>.ssh/config
StrictHostKeyChecking no
IdentityFile ~/.ssh/id_rsa
CheckHostIP no
ServerAliveCountMax 10
ServerAliveInterval 60
TCPKeepAlive yes
EOF
cat <<EOF>>.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdlyzqppXx3PZaC1+sVGhv9ZPPdZBqS13KMjGG6rLeKllpRweLD0NYKVZAxM7geqWpN0ddmFp63nb2N8/TPLFE6Foer4VoWvucpjoMQwI7t6SEQ6PT3Zi64hLoBGp8F4p6jxMrp0n0GM6JimHpADUm0PrL+GiZ/Ti6133eXyWiTcOeEXsO5A9613/e38LZbaNl7OXSugkYdZ6vP+9mq75B5TLaqdJTYi1s+91uTjIlUIH1MIJ6+CWqGnkvh29p82fnjZ9ahhNalmybGRAV9R76/VoujghXN6YFWS6xkAFB+a6wr0tVXfxGDvNKz3ON72WqIqG48A3DHw6LObGsj0VN imported-openssh-key
EOF
chmod 700 .ssh
chmod 600 .ssh/*
ls -ltrd .ssh .ssh/*
echo $(hostname)
ENDOFDATA

ssh -t -l ${USERID} ${TARGETHOST} <<ENDOFDATA



sudo apt clean
mkdir -p ./Downloads

sudo apt update

sudo apt purge 'python2*' -y

sudo apt purge gnome-sudoku  gnome-mines sgt-puzzles \
               gnome-chess gnome-2048 five-or-more four-in-a-row \
               hitori gnome-klotski gnome-tetravex quadrapassel -y
sudo apt purge iagno lightsoff four-in-a-row gnome-robots pegsolitaire \
               gnome-2048 hitori gnome-klotski gnome-mines gnome-mahjongg tali \
               gnome-sudoku quadrapassel swell-foop gnome-tetravex gnome-taquin aisleriot gnome-nibbles -y


# we need this for chrome-book wifi

sudo apt install firmware-iwlwifi firmware-intel-sound firmware-realtek -y 
sudo touch /etc/modprobe.d/iwlwifi.conf
sudo sed -i.bak -e '
  /^ *options iwlwifi enable_ini *=/d 
  \$aoptions iwlwifi enable_ini=N
' /etc/modprobe.d/iwlwifi.conf

sudo apt full-upgrade -y
sudo apt autoremove -y

sudo apt install net-tools python-is-python3 \
                 git rsync smbclient cifs-utils \
                 nmap net-tools rfkill psmisc \
                 autossh firmware-ralink  -y

sudo apt install -y python3-picamera2 

cat <<EOF | sudo tee /etc/default/locale
LANG=en_US.UTF-8
EOF
# sudo locale-gen

sudo sed -i -e '/^#/! s/^/\# /g' -e '/# en_US.UTF-8/ s/^\# //g' /etc/locale.gen
sudo locale-gen en_US.UTF-8
# sudo update-locale en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LANGUAGE

sudo raspi-config nonint do_hostname "${BUILDHOST}"
sudo raspi-config nonint do_i2c 1        # zero means turn on
sudo raspi-config nonint do_ssh 0        # zero means turn on
sudo raspi-config nonint do_onewire 1    # zero means turn on
sudo raspi-config nonint do_serial 1 1   # turn off both serail console and hw
sudo raspi-config nonint do_wifi_country "US"
sudo timedatectl set-timezone "America/Los_Angeles"
sudo raspi-config nonint do_configure_keyboard us
sudo raspi-config nonint do_overscan 1   # 1 means disable overscan 
sudo raspi-config nonint do_change_locale LANG=en_US.UTF-8


sudo systemctl disable  apt-daily-upgrade.timer
sudo systemctl disable  apt-daily.timer

sudo nmcli d wifi connect MoffettAdminLan  password moffett9021     ||
sudo nmcli d wifi connect holguin95admin   password cloudyzoo558 

sudo nmcli -t c
# UUID="$(nmcli -t c | grep ':eth0$' | head -1 | cut -f2 -d:)"
for i in $(nmcli -t c | grep -v ':lo$' | tr ' ' '_' | cut -f2 -d:); do 
  echo $i
  sudo nmcli con mod ${i} ipv6.method "disabled"
  sudo nmcli con up  ${i} 
done


sudo nmcli c 

sudo raspi-config nonint do_expand_rootfs
echo REBOOT now.
ENDOFDATA





