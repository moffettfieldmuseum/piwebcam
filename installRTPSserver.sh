#!/usr/bin/env bash
set -u
uname -m
rm -rf  ~/mediamtx
mkdir -p  ~/mediamtx
mkdir -p ~/Downloads
cd  ~/Downloads
rm -f  mediamtx*
wget https://github.com/bluenviron/mediamtx/releases/download/v1.9.3/mediamtx_v1.9.3_linux_arm64v8.tar.gz 
cd ~/mediamtx
tar -zxf ~/Downloads/mediamtx*
sed -i -e  '
  /rpiCameraHFlip:/ s/:.*$/: true/
  /rpiCameraVFlip:/ s/:.*$/: true/
  /^paths:/a \
  cam:\
    source: rpiCamera\
    sourceProtocol: automatic\

'  mediamtx.yml

sudo systemctl stop  mediamtx.service
sudo systemctl disable  mediamtx.service

sudo tee /etc/systemd/system/mediamtx.service >/dev/null << EOF
[Unit]
Wants=network.target
[Service]
ExecStart=$(pwd)/mediamtx $(pwd)/mediamtx.yml
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable  mediamtx.service
