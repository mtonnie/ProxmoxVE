#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: mtonnie (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/androidseb25/iGotify-Notification-Assistent/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing ASP.NET Core Runtime"
curl -fsSL "https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb" -o packages-microsoft-prod.deb
$STD dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
$STD apt-get update
$STD apt-get install -y aspnetcore-runtime-9.0
msg_ok "Installed ASP.NET Core Runtime"

msg_info "Installing iGotify"
curl -fsSL "https://github.com/androidseb25/iGotify-Notification-Assistent/releases/download/v1.3.1.0/iGotify-Notification-Service-amd64-v1.3.1.0.zip" -o "iGotify-Notification-Service.zip"
$STD unzip -o iGotify-Notification-Service.zip -d /opt/igotify
rm iGotify-Notification-Service.zip
msg_ok "Installed iGotify"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/igotify.service
[Unit]
Description=iGotify Service

[Service]
WorkingDirectory=/opt/igotify
ExecStart=/usr/bin/dotnet 'iGotify Notification Assist.dll'
SyslogIdentifier=igotify
User=root

[Install]
WantedBy=multi-user.target
EOF
$STD systemctl enable -q --now igotify
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
