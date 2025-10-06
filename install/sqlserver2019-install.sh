#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Kristian Skov
# License: MIT | https://github.com/HendrikHaase/ProxmoxVE/raw/main/LICENSE
# Source: https://www.microsoft.com/en-us/sql-server/sql-server-2019

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl gnupg
msg_ok "Installed Dependencies"

msg_info "Adding Microsoft repository and key"
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/20.04/mssql-server-2019 focal main" > /etc/apt/sources.list.d/mssql-server-2019.list
msg_ok "Added Microsoft repository and key"

msg_info "Installing Microsoft SQL Server 2019"
$STD apt-get update
MSSQL_SA_PASSWORD="P@ssw0rd" MSSQL_PID="evaluation" $STD apt-get install -y mssql-server
msg_ok "Installed Microsoft SQL Server 2019"

msg_info "Installing SQL Server command-line tools"
echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/20.04/prod focal main" > /etc/apt/sources.list.d/mssql-tools.list
$STD apt-get update
ACCEPT_EULA=Y $STD apt-get install -y mssql-tools unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
msg_ok "Installed SQL Server command-line tools"

msg_info "Starting and enabling Microsoft SQL Server"
$STD systemctl enable mssql-server
$STD systemctl start mssql-server
msg_ok "Started and enabled Microsoft SQL Server"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
