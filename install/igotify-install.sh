#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Martin Tonnier (mtonnie)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/androidseb25/iGotify-Notification-Assistent

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing ASP.NET Core Runtime"
temp_dir=$(mktemp -d)
cd $temp_dir
curl -fsSL "https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb" -o packages-microsoft-prod.deb
$STD dpkg -i packages-microsoft-prod.deb
$STD apt-get update
$STD apt-get install -y aspnetcore-runtime-9.0
msg_ok "Installed ASP.NET Core Runtime"

msg_info "Installing iGotify"
RELEASE=$(curl -fsSL https://api.github.com/repos/androidseb25/iGotify-Notification-Assistent/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
curl -fsSL "https://github.com/androidseb25/iGotify-Notification-Assistent/releases/download/v${RELEASE}/iGotify-Notification-Service-amd64-v${RELEASE}.zip" -o "iGotify-Notification-Service.zip"
$STD unzip -o iGotify-Notification-Service.zip -d $temp_dir
mv $temp_dir/iGotify-Notification-Service-amd64 /opt/igotify
cat <<EOF >/opt/igotify/env.conf
#GOTIFY_URLS=http://gotify
#GOTIFY_CLIENT_TOKENS=cXXXXXXXX1
#SECNTFY_TOKENS=NTFY-DEVICE-XXXXXX1

ASPNETCORE_URLS=http://0.0.0.0:5000
EOF
echo "${RELEASE}" > /opt/iGotify_version.txt
msg_ok "Installed iGotify"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/igotify.service
[Unit]
Description=iGotify Service

[Service]
WorkingDirectory=/opt/igotify
Environment="ASPNETCORE_URLS=http://0.0.0.0:80"
ExecStart=/usr/bin/dotnet 'iGotify Notification Assist.dll'
ExecStop=/bin/kill \${MAINPID}
KillSignal=SIGTERM
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
rm -rf $temp_dir
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
