#!/bin/bash

tput clear

green="\e[32m"
red="\e[31m"
yellow="\e[33m"
blue="\e[34m"
reset="\e[0m"

BASE_URL="https://github.com/Musixal/Backhaul/releases/download/v0.6.5"
BACKHAUL_PATH="/root/backhaul"
SHORTCUT_PATH="/usr/local/bin/backhaul-menu"
CONFIG_DIR="/root"

# Check prerequisites
for cmd in wget tar systemctl; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo "${red}Error: Required command '$cmd' is not installed. Please install it first.${reset}"
        exit 1
    fi
done

check_port() {
    local PORT=$1
    if netstat -tuln | grep -q ":$PORT "; then
        return 1
    fi
    return 0
}

config_server() {
    local CONFIG_FILE=$1
    local TRANSPORT=$2
    local DEFAULT_PORT=$3

    read -p "Enter tunnel port (bind_addr) [Default: 3080]: " BIND_PORT
    BIND_PORT=${BIND_PORT:-$DEFAULT_PORT}
    while ! check_port $BIND_PORT; do
        echo "${red}Error: Port $BIND_PORT is already in use. Please enter a different port.${reset}"
        read -p "Enter tunnel port: " BIND_PORT
    done
    read -p "Enter transport [Default: tcpmux]: " TRANSPORT_INPUT
    TRANSPORT=${TRANSPORT_INPUT:-$TRANSPORT}
    read -p "Enter token [Default: your_token]: " TOKEN
    TOKEN=${TOKEN:-"your_token"}
    read -p "Enter keepalive_period [Default: 75]: " KEEPALIVE_PERIOD
    KEEPALIVE_PERIOD=${KEEPALIVE_PERIOD:-75}
    read -p "Enter nodelay (true/false) [Default: true]: " NODELAY
    NODELAY=${NODELAY:-true}
    read -p "Enter heartbeat [Default: 40]: " HEARTBEAT
    HEARTBEAT=${HEARTBEAT:-40}
    read -p "Enter channel_size [Default: 2048]: " CHANNEL_SIZE
    CHANNEL_SIZE=${CHANNEL_SIZE:-2048}
    read -p "Enter mux_con [Default: 8]: " MUX_CON
    MUX_CON=${MUX_CON:-8}
    read -p "Enter mux_version [Default: 1]: " MUX_VERSION
    MUX_VERSION=${MUX_VERSION:-1}
    read -p "Enter mux_framesize [Default: 32768]: " MUX_FRAMESIZE
    MUX_FRAMESIZE=${MUX_FRAMESIZE:-32768}
    read -p "Enter mux_recievebuffer [Default: 4194304]: " MUX_RECEIVEBUFFER
    MUX_RECEIVEBUFFER=${MUX_RECEIVEBUFFER:-4194304}
    read -p "Enter mux_streambuffer [Default: 65536]: " MUX_STREAMBUFFER
    MUX_STREAMBUFFER=${MUX_STREAMBUFFER:-65536}
    read -p "Enable sniffer (true/false) [Default: false]: " SNIFFER
    SNIFFER=${SNIFFER:-false}
    read -p "Enter web_port [Default: 2060]: " WEB_PORT
    WEB_PORT=${WEB_PORT:-2060}
    read -p "Enter sniffer_log [Default: /root/backhaul.json]: " SNIFFER_LOG
    SNIFFER_LOG=${SNIFFER_LOG:-"/root/backhaul.json"}
    read -p "Enter log_level (info/debug/error) [Default: info]: " LOG_LEVEL
    LOG_LEVEL=${LOG_LEVEL:-"info"}
    read -p "Enter ports (comma-separated) [Default: none]: " PORTS
    PORTS=${PORTS:-}

    echo "[server]" > "$CONFIG_FILE"
    echo "bind_addr = \"0.0.0.0:$BIND_PORT\"" >> "$CONFIG_FILE"
    echo "transport = \"$TRANSPORT\"" >> "$CONFIG_FILE"
    echo "token = \"$TOKEN\"" >> "$CONFIG_FILE"
    echo "keepalive_period = $KEEPALIVE_PERIOD" >> "$CONFIG_FILE"
    echo "nodelay = $NODELAY" >> "$CONFIG_FILE"
    echo "heartbeat = $HEARTBEAT" >> "$CONFIG_FILE"
    echo "channel_size = $CHANNEL_SIZE" >> "$CONFIG_FILE"
    echo "mux_con = $MUX_CON" >> "$CONFIG_FILE"
    echo "mux_version = $MUX_VERSION" >> "$CONFIG_FILE"
    echo "mux_framesize = $MUX_FRAMESIZE" >> "$CONFIG_FILE"
    echo "mux_recievebuffer = $MUX_RECEIVEBUFFER" >> "$CONFIG_FILE"
    echo "mux_streambuffer = $MUX_STREAMBUFFER" >> "$CONFIG_FILE"
    echo "sniffer = $SNIFFER" >> "$CONFIG_FILE"
    echo "web_port = $WEB_PORT" >> "$CONFIG_FILE"
    echo "sniffer_log = \"$SNIFFER_LOG\"" >> "$CONFIG_FILE"
    echo "log_level = \"$LOG_LEVEL\"" >> "$CONFIG_FILE"
    echo "ports = [\"${PORTS//,/\", \"}\"]" >> "$CONFIG_FILE"

    echo -e "${green}Server configuration saved in $CONFIG_FILE${reset}"
}

config_client() {
    local CONFIG_FILE=$1
    local TRANSPORT=$2
    local REMOTE_IP_DEFAULT=$3
    local REMOTE_PORT_DEFAULT=$4

    read -p "Enter remote server IP [Default: $REMOTE_IP_DEFAULT]: " REMOTE_IP
    REMOTE_IP=${REMOTE_IP:-$REMOTE_IP_DEFAULT}
    read -p "Enter remote port [Default: $REMOTE_PORT_DEFAULT]: " REMOTE_PORT
    REMOTE_PORT=${REMOTE_PORT:-$REMOTE_PORT_DEFAULT}
    read -p "Enter token [Default: your_token]: " TOKEN
    TOKEN=${TOKEN:-"your_token"}
    read -p "Enter connection_pool [Default: 8]: " CONNECTION_POOL
    CONNECTION_POOL=${CONNECTION_POOL:-8}
    read -p "Enter aggressive_pool (true/false) [Default: false]: " AGGRESSIVE_POOL
    AGGRESSIVE_POOL=${AGGRESSIVE_POOL:-false}
    read -p "Enter keepalive_period [Default: 75]: " KEEPALIVE_PERIOD
    KEEPALIVE_PERIOD=${KEEPALIVE_PERIOD:-75}
    read -p "Enter dial_timeout [Default: 10]: " DIAL_TIMEOUT
    DIAL_TIMEOUT=${DIAL_TIMEOUT:-10}
    read -p "Enter retry_interval [Default: 3]: " RETRY_INTERVAL
    RETRY_INTERVAL=${RETRY_INTERVAL:-3}
    read -p "Enter nodelay (true/false) [Default: true]: " NODELAY
    NODELAY=${NODELAY:-true}
    read -p "Enter mux_version [Default: 1]: " MUX_VERSION
    MUX_VERSION=${MUX_VERSION:-1}
    read -p "Enter mux_framesize [Default: 32768]: " MUX_FRAMESIZE
    MUX_FRAMESIZE=${MUX_FRAMESIZE:-32768}
    read -p "Enter mux_recievebuffer [Default: 4194304]: " MUX_RECEIVEBUFFER
    MUX_RECEIVEBUFFER=${MUX_RECEIVEBUFFER:-4194304}
    read -p "Enter mux_streambuffer [Default: 65536]: " MUX_STREAMBUFFER
    MUX_STREAMBUFFER=${MUX_STREAMBUFFER:-65536}
    read -p "Enable sniffer (true/false) [Default: false]: " SNIFFER
    SNIFFER=${SNIFFER:-false}
    read -p "Enter web_port [Default: 2060]: " WEB_PORT
    WEB_PORT=${WEB_PORT:-2060}
    read -p "Enter sniffer_log [Default: /root/backhaul.json]: " SNIFFER_LOG
    SNIFFER_LOG=${SNIFFER_LOG:-"/root/backhaul.json"}
    read -p "Enter log_level (info/debug/error) [Default: info]: " LOG_LEVEL
    LOG_LEVEL=${LOG_LEVEL:-"info"}

    echo "[client]" > "$CONFIG_FILE"
    echo "remote_addr = \"$REMOTE_IP:$REMOTE_PORT\"" >> "$CONFIG_FILE"
    echo "transport = \"$TRANSPORT\"" >> "$CONFIG_FILE"
    echo "token = \"$TOKEN\"" >> "$CONFIG_FILE"
    echo "connection_pool = $CONNECTION_POOL" >> "$CONFIG_FILE"
    echo "aggressive_pool = $AGGRESSIVE_POOL" >> "$CONFIG_FILE"
    echo "keepalive_period = $KEEPALIVE_PERIOD" >> "$CONFIG_FILE"
    echo "dial_timeout = $DIAL_TIMEOUT" >> "$CONFIG_FILE"
    echo "retry_interval = $RETRY_INTERVAL" >> "$CONFIG_FILE"
    echo "nodelay = $NODELAY" >> "$CONFIG_FILE"
    echo "mux_version = $MUX_VERSION" >> "$CONFIG_FILE"
    echo "mux_framesize = $MUX_FRAMESIZE" >> "$CONFIG_FILE"
    echo "mux_recievebuffer = $MUX_RECEIVEBUFFER" >> "$CONFIG_FILE"
    echo "mux_streambuffer = $MUX_STREAMBUFFER" >> "$CONFIG_FILE"
    echo "sniffer = $SNIFFER" >> "$CONFIG_FILE"
    echo "web_port = $WEB_PORT" >> "$CONFIG_FILE"
    echo "sniffer_log = \"$SNIFFER_LOG\"" >> "$CONFIG_FILE"
    echo "log_level = \"$LOG_LEVEL\"" >> "$CONFIG_FILE"

    echo -e "${green}Client configuration saved in $CONFIG_FILE${reset}"
}

configure_tcp_mux() {
    echo -e "${blue}Configuring TCP MUX...${reset}"
    echo -e "${yellow}Is the server located in Iran or abroad?${reset}"
    echo -e "${green}1)  IRAN${reset}\n${red}2)  ABROAD${reset}\n"
    read -p "Enter your choice (1 or 2): " SERVER_LOCATION

    if [ "$SERVER_LOCATION" -eq 1 ]; then
        config_server "$CONFIG_DIR/config.toml" "tcpmux" 3080
    else
        config_client "$CONFIG_DIR/config.toml" "tcpmux" "0.0.0.0" 3080
        create_service_files
    fi
}

configure_ws() {
    echo -e "${green}Configuring WS...${reset}"
    echo -e "${yellow}Is the server located in Iran or abroad?${reset}"
    echo -e "${green}1)  IRAN${reset}\n${red}2)  ABROAD${reset}\n"
    read -p "Enter your choice (1 or 2): " SERVER_LOCATION

    if [ "$SERVER_LOCATION" -eq 1 ]; then
        config_server "$CONFIG_DIR/config.toml" "ws" 8080
    else
        config_client "$CONFIG_DIR/config.toml" "ws" "0.0.0.0" 8080
        create_service_files
    fi
}

create_new_config() {
    echo -e "${blue}Creating a new configuration...${reset}"
    echo -e "${yellow}What type of configuration do you want to create?${reset}"
    echo -e "${green}1)  SERVER${reset}\n${red}2)  CLIENT${reset}\n"
    read -p "Enter your choice (1 or 2): " CONFIG_TYPE

    read -p "Enter the name for the new config file (e.g., config_new.toml): " NEW_CONFIG_NAME
    NEW_CONFIG_PATH="$CONFIG_DIR/$NEW_CONFIG_NAME"

    echo -e "${yellow}Choose the transport protocol:${reset}"
    echo -e "${green}1)  TCP MUX${reset}\n${red}2)  WS${reset}\n"
    read -p "Enter your choice (1 or 2): " TRANSPORT_CHOICE
    if [ "$TRANSPORT_CHOICE" -eq 1 ]; then
        TRANSPORT="tcpmux"
        DEFAULT_PORT=3080
    else
        TRANSPORT="ws"
        DEFAULT_PORT=8080
    fi

    if [ "$CONFIG_TYPE" -eq 1 ]; then
        config_server "$NEW_CONFIG_PATH" "$TRANSPORT" $DEFAULT_PORT
    else
        read -p "Enter remote server IP [Default: 0.0.0.0]: " REMOTE_IP
        REMOTE_IP=${REMOTE_IP:-"0.0.0.0"}
        read -p "Enter remote port [Default: $DEFAULT_PORT]: " REMOTE_PORT
        REMOTE_PORT=${REMOTE_PORT:-$DEFAULT_PORT}
        config_client "$NEW_CONFIG_PATH" "$TRANSPORT" "$REMOTE_IP" "$REMOTE_PORT"
    fi

    SERVICE_NAME="backhaul-$(basename $NEW_CONFIG_NAME .toml)"
    echo "[Unit]
Description=Backhaul Reverse Tunnel Service ($(basename $NEW_CONFIG_NAME .toml))
After=network.target

[Service]
Type=simple
ExecStart=/root/backhaul -c $NEW_CONFIG_PATH
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/$SERVICE_NAME.service

    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE_NAME.service
    sudo systemctl start $SERVICE_NAME.service
    echo -e "${green}$SERVICE_NAME.service enabled and started!${reset}"
}

create_service_files() {
    echo "[Unit]
Description=Backhaul Reverse Tunnel Service
After=network.target

[Service]
Type=simple
ExecStart=/root/backhaul -c /root/config.toml
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/backhaul.service

    sudo systemctl daemon-reload
    sudo systemctl enable backhaul.service
    sudo systemctl start backhaul.service
    echo -e "${green}backhaul.service enabled and started!${reset}"
}

manage_services() {
    echo -e "${blue}================================="
    echo -e "            Manage Services            "
    echo -e "=================================${reset}\n"

    CONFIG_FILES=("$CONFIG_DIR"/*.toml)
    if [ ${#CONFIG_FILES[@]} -eq 0 ] || [ ! -f "${CONFIG_FILES[0]}" ]; then
        echo -e "${red}No configuration files found!${reset}"
        read -p "Press Enter to continue..."
        return
    fi

    echo -e "${yellow}List of available config files:${reset}"
    declare -A service_map
    for i in "${!CONFIG_FILES[@]}"; do
        CONFIG_FILE="${CONFIG_FILES[$i]}"
        SERVICE_NAME="backhaul-$(basename "$CONFIG_FILE" .toml)"
        if [ "$(basename "$CONFIG_FILE")" = "config.toml" ]; then
            SERVICE_NAME="backhaul"
        fi
        echo "$((i+1))) $(basename "$CONFIG_FILE") (Service: $SERVICE_NAME.service)"
        service_map[$i]="$SERVICE_NAME"
    done
    echo "$((i+2))) All Services"

    read -p "Select the config file number (or $((i+2)) for all, or 0 to go back): " CONFIG_INDEX
    if [ "$CONFIG_INDEX" -eq 0 ]; then
        return
    fi

    if [ "$CONFIG_INDEX" -eq $((i+2)) ]; then
        for svc in "${service_map[@]}"; do
            systemctl restart "$svc.service" 2>/dev/null && echo "${green}Restarted $svc.service${reset}" || echo "${red}Failed to restart $svc.service${reset}"
        done
        read -p "Press Enter to continue..."
        return
    fi

    CONFIG_INDEX=$((CONFIG_INDEX-1))
    if [ -z "${service_map[$CONFIG_INDEX]}" ]; then
        echo -e "${red}Invalid selection!${reset}"
        read -p "Press Enter to continue..."
        return
    fi

    SELECTED_SERVICE="${service_map[$CONFIG_INDEX]}"
    while true; do
        echo -e "\n${blue}================================="
        echo -e "    Managing Service: $SELECTED_SERVICE.service    "
        echo -e "=================================${reset}\n"
        echo -e "${green}1)  Restart Service${reset}\n"
        echo -e "${yellow}2)  Check Service Status${reset}\n"
        echo -e "${red}3)  Back${reset}\n"
        read -p "Choose an option (1-3): " SERVICE_ACTION
        case $SERVICE_ACTION in
            1)
                systemctl restart "$SELECTED_SERVICE.service"
                if [ $? -eq 0 ]; then
                    echo -e "${green}Service $SELECTED_SERVICE.service restarted successfully!${reset}"
                else
                    echo -e "${red}Failed to restart service $SELECTED_SERVICE.service${reset}"
                fi
                read -p "Press Enter to continue..."
                ;;
            2)
                systemctl status "$SELECTED_SERVICE.service"
                read -p "Press Enter to continue..."
                ;;
            3)
                break
                ;;
            *)
                echo -e "${red}Invalid choice!${reset}"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

uninstall_backhaul() {
    echo -e "${yellow}Starting complete uninstallation of Backhaul...${reset}"

    # متوقف کردن و غیرفعال کردن تمام سرویس‌های مرتبط با Backhaul
    echo -e "${blue}Stopping and disabling all Backhaul services...${reset}"
    for service in $(systemctl list-units --full -all | grep "backhaul" | awk '{print $1}'); do
        systemctl stop "$service" 2>/dev/null && echo "${green}Stopped $service${reset}" || echo "${yellow}Could not stop $service${reset}"
        systemctl disable "$service" 2>/dev/null && echo "${green}Disabled $service${reset}" || echo "${yellow}Could not disable $service${reset}"
    done

    # حذف تمام فایل‌های سرویس systemd مرتبط
    echo -e "${blue}Removing all Backhaul service files...${reset}"
    rm -f /etc/systemd/system/backhaul*.service && echo "${green}Service files removed${reset}" || echo "${yellow}Failed to remove service files${reset}"
    systemctl daemon-reload && echo "${green}Systemd reloaded${reset}" || echo "${yellow}Failed to reload systemd${reset}"

    # حذف فایل اجرایی Backhaul
    echo -e "${blue}Removing Backhaul binary...${reset}"
    if [ -f "$BACKHAUL_PATH" ]; then
        rm -f "$BACKHAUL_PATH" && echo "${green}Backhaul binary removed${reset}" || echo "${red}Failed to remove $BACKHAUL_PATH${reset}"
    fi

    # حذف تمام فایل‌های کانفیگ در دایرکتوری CONFIG_DIR
    echo -e "${blue}Removing all configuration files...${reset}"
    if [ -d "$CONFIG_DIR" ]; then
        find "$CONFIG_DIR" -type f -name "*.toml" -exec rm -f {} \; && echo "${green}All config files removed${reset}" || echo "${yellow}Failed to remove some config files${reset}"
    fi

    # حذف شورت‌کات
    echo -e "${blue}Removing shortcut...${reset}"
    if [ -f "$SHORTCUT_PATH" ]; then
        rm -f "$SHORTCUT_PATH" && echo "${green}Shortcut removed${reset}" || echo "${red}Failed to remove $SHORTCUT_PATH${reset}"
    fi

    # حذف فایل‌های لاگ احتمالی (مثل sniffer log)
    echo -e "${blue}Removing possible log files...${reset}"
    if [ -f "/root/backhaul.json" ]; then
        rm -f "/root/backhaul.json" && echo "${green}Default sniffer log removed${reset}" || echo "${yellow}Failed to remove /root/backhaul.json${reset}"
    fi

    # جستجو و حذف هر فایل لاگ دیگه‌ای که توی کانفیگ‌ها مشخص شده
    if [ -d "$CONFIG_DIR" ]; then
        find "$CONFIG_DIR" -type f -name "*.toml" -exec grep -i "sniffer_log" {} \; | cut -d'"' -f2 | sort -u | while read -r log_file; do
            if [ -f "$log_file" ]; then
                rm -f "$log_file" && echo "${green}Removed log file: $log_file${reset}" || echo "${yellow}Failed to remove $log_file${reset}"
            fi
        done
    fi

    # بررسی نهایی و پیام اتمام
    if [ ! -f "$BACKHAUL_PATH" ] && [ ! -f "$SHORTCUT_PATH" ] && [ -z "$(ls $CONFIG_DIR/*.toml 2>/dev/null)" ] && [ -z "$(systemctl list-units --full -all | grep "backhaul")" ]; then
        echo -e "${green}Backhaul completely uninstalled!${reset}"
    else
        echo -e "${red}Uninstallation completed with warnings. Some files or services may remain.${reset}"
    fi

    exit 0
}

show_menu() {
    echo -e "\n${blue}================================="
    echo -e "            BACKHAUL CONFIG MENU            "
    echo -e "=================================${reset}\n"
    echo -e "${red}1)  CONFIGURE TCP MUX${reset}\n"
    echo -e "${green}2)  CONFIGURE WS${reset}\n"
    echo -e "${yellow}3)  CREATE NEW CONFIG${reset}\n"
    echo -e "${blue}4)  MANAGE SERVICES${reset}\n"
    echo -e "${red}5)  UNINSTALL BACKHAUL${reset}\n"
    echo -e "${blue}6)  EXIT${reset}\n"
    read -p "Enter your choice (1-6): " CONFIG_CHOICE
}

create_shortcut() {
    cat << 'EOF' > $SHORTCUT_PATH
#!/bin/bash
source <(declare -f config_server config_client configure_tcp_mux configure_ws create_new_config create_service_files manage_services uninstall_backhaul show_menu check_port)
source <(declare -p green red yellow blue reset CONFIG_DIR BACKHAUL_PATH SHORTCUT_PATH)
while true; do tput clear; show_menu; case $CONFIG_CHOICE in
    1|2) [ $CONFIG_CHOICE -eq 1 ] && configure_tcp_mux || configure_ws; create_service_files;;
    3) create_new_config;;
    4) manage_services;;
    5) uninstall_backhaul;;
    6) exit;;
    *) echo "${red}Invalid!${reset}";;
esac; done
EOF
    chmod +x $SHORTCUT_PATH && echo "${green}Shortcut created! Use 'backhaul-menu'.${reset}" || echo "${red}Shortcut failed!${reset}"
}

if [ -f "$BACKHAUL_PATH" ]; then
    echo "${green}Backhaul installed!${reset}"
else
    ARCH=$(dpkg --print-architecture)
    FILE_NAME="backhaul_linux_${ARCH}.tar.gz"
    MAX_RETRIES=3
    RETRY_COUNT=0
    until [ $RETRY_COUNT -ge $MAX_RETRIES ]; do
        wget -O "$FILE_NAME" "$BASE_URL/$FILE_NAME" && break
        RETRY_COUNT=$((RETRY_COUNT+1))
        echo "${red}Download failed (Attempt $RETRY_COUNT/$MAX_RETRIES). Retrying...${reset}"
        sleep 2
    done
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "${red}Failed to download after $MAX_RETRIES attempts. Check your internet connection or the URL: $BASE_URL/$FILE_NAME${reset}"
        exit 1
    fi
    # Extract the tar.gz file
    tar -xzf "$FILE_NAME"
    # Move the backhaul binary to the desired location
    mv backhaul $BACKHAUL_PATH && chmod +x $BACKHAUL_PATH
    # Get the list of files extracted from the tar.gz (excluding directories)
    tar -tf "$FILE_NAME" | grep -v "/$" | while read -r extracted_file; do
        # Skip the backhaul file itself
        if [ "$extracted_file" != "backhaul" ]; then
            rm -f "$extracted_file" && echo "${green}Removed extracted file: $extracted_file${reset}" || echo "${red}Failed to remove $extracted_file${reset}"
        fi
    done
    # Remove the tar.gz file itself
    rm -f "$FILE_NAME" && echo "${green}Removed $FILE_NAME${reset}" || echo "${red}Failed to remove $FILE_NAME${reset}"
    echo "${green}Installed!${reset}"
    create_shortcut
fi

while true; do
    tput clear
    show_menu
    case $CONFIG_CHOICE in
        1|2) [ $CONFIG_CHOICE -eq 1 ] && configure_tcp_mux || configure_ws;;
        3) create_new_config;;
        4) manage_services;;
        5) uninstall_backhaul;;
        6) exit;;
        *) echo "${red}Invalid!${reset}";;
    esac
done
