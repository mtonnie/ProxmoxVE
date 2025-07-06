#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Martin Tonnier (mtonnie)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/androidseb25/iGotify-Notification-Assistent

APP="iGotify"
var_tags="${var_tags:-notification}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/igotify/ ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  RELEASE=$(curl -fsSL https://api.github.com/repos/androidseb25/iGotify-Notification-Assistent/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Stopping ${APP}"
    systemctl stop igotify
    msg_ok "Stopped ${APP}"

    msg_info "Updating ${APP} to v${RELEASE}"
    mkdir -p igotify-backup
    cp -R /opt/igotify/appsettings.json igotify-backup/
    curl -fsSL "https://github.com/androidseb25/iGotify-Notification-Assistent/releases/download/v${RELEASE}/iGotify-Notification-Service-amd64-v${RELEASE}.zip" -o "iGotify-Notification-Service.zip"
    $STD unzip -o iGotify-Notification-Service.zip -d /opt/igotify
    cp -R igotify-backup/appsettings.json /opt/igotify/
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated $APP to v${RELEASE}"

    msg_info "Starting ${APP}"
    systemctl start igotify
    msg_ok "Started ${APP}"

    msg_info "Cleaning Up"
    rm -rf igotify-backup iGotify-Notification-Service.zip
    msg_ok "Cleaned"
    msg_ok "Updated Successfully"
  else
    msg_ok "No update required. ${APP} is already at ${RELEASE}"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:6500${CL}"
