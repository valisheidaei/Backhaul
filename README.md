# Backhaul Installer Script

Welcome to the **Backhaul Installer Script**! This is a Bash script designed to simplify the installation, configuration, and management of the Backhaul reverse tunnel tool. With an interactive menu, you can easily set up servers or clients, manage services, and uninstall the tool when needed.

## Features
- Automatic download and installation of Backhaul (version 0.6.5).
- Interactive configuration for TCP MUX and WS transports.
- Support for both server and client setups.
- Service management with systemd integration.
- Complete uninstallation option to remove all files and services.
- Color-coded user interface for better experience.

## Prerequisites
Before running the script, ensure the following tools are installed on your system:
- `wget`
- `tar`
- `systemctl`

These are typically available on most Linux distributions. Install them if missing (e.g., `sudo apt install wget tar systemd` on Debian-based systems).

## Installation
To install Backhaul and start using the script, simply run the following command in your terminal:

```bash
bash -c "$(wget -qO- https://raw.githubusercontent.com/valisheidaei/Backhaul/refs/heads/main/install.sh)"
