#!/usr/bin/env bash
set -xv
if [[ 1 == 0 ]]; then
  : # do nothing
fi

sudo apt update -y
sudo apt install raspi-config  -y

sudo apt purge 'python2*' -y

sudo apt upgrade -y
sudo apt autoremove -y


sudo passwd pi<<EOF
p6223989!
p6223989!
EOF

cat <<EOF | sudo tee /etc/default/locale
LANG=en_US.UTF-8
EOF
# sudo locale-gen

sudo sed -i -e '/^#/! s/^/\# /g' -e '/# en_US.UTF-8/ s/^\# //g' /etc/locale.gen
sudo locale-gen en_US.UTF-8
# sudo update-locale en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LANGUAGE

sudo raspi-config nonint do_hostname "test-raspi-zero"
sudo raspi-config nonint do_i2c 0        # zero means turn on
sudo raspi-config nonint do_ssh 0        # zero means turn on
sudo raspi-config nonint do_onewire 0    # zero means turn on
sudo raspi-config nonint do_serial 1 1   # turn off both serail console and hw
sudo raspi-config nonint do_wifi_country "US"
sudo timedatectl set-timezone "America/Los_Angeles"
sudo raspi-config nonint do_configure_keyboard us
sudo raspi-config nonint do_overscan 1   # 1 means disable overscan 
sudo raspi-config nonint do_change_locale LANG=en_US.UTF-8

if [[ ! -f ~pi/.ssh/authorized_keys ]]; then
  if [[ -d /boot/.ssh ]]; then
    mkdir ~pi/.ssh
    chmod 700 ~pi/.ssh
    sudo cp /boot/.ssh/* ~pi/.ssh/.
    sudo chown pi:pi ~pi/.ssh ~pi/.ssh/*
    chmod 600 ~pi/.ssh/*
  fi
fi

grep javaxpresso.com /etc/resolvconf.conf  || sudo sed -i -e '$a\
replace_sub="domain/*/javaxpresso.com search/*/javaxpresso.com"'  /etc/resolvconf.conf


sudo raspi-config nonint do_expand_rootfs


echo REBOOT now.
