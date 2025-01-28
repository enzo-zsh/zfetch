#!/bin/sh
#    zfetch - a fast but pretty fetch script (macOS version)
#    Adapted from jornmann's original work
#    Copyright (C) 2022 jornmann
#    Forked by enzo-zsh
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Variables and defaults
nc="\033[0m"

# Detect macOS version
NAME="$(sw_vers -productName)"

# macOS logo
dscolor="\033[0;37m" # white
dslogo1="      ,--./.-.    "
dslogo2="     / #      \   "
dslogo3="    ︱       〈   "
dslogo4="     \        /   "
dslogo5="      '._,._,'    "
dslogo6="                  "
dslogo7="                  "
dslogo8="                  "
dslogo9="                  "

# Command line parameters handling
if [ "$arg" = "" ]; then
    arg=""
elif [ "$arg" = "nologo" ]; then
    unset dslogo
elif [ "$arg" = "nofetch" ]; then
    printf "${dscolor}${dslogo1}\n${dslogo2}\n${dslogo3}\n${dslogo4}\n${dslogo5}\n${dslogo6}\n${dslogo7}\n${dslogo8}\n${dslogo9}\n${nc}"
    exit
fi

# Config file sourcing
if [ "$colorsoff" = "" ]; then
    colorsoff=0
fi
[ -e /etc/zfetchrc ] && . /etc/zfetchrc 2> /dev/null
[ -e ~/.zfetchrc ] && . ~/.zfetchrc 2> /dev/null

# System information gathering for macOS
host=$(hostname)
kernel=$(uname -r)
uptime=$(uptime | sed 's/.*up \([^,]*\),.*/\1/')
shell=$(basename "$SHELL")
os_version="$(sw_vers -productVersion)"

# CPU information
cpu=$(sysctl -n machdep.cpu.brand_string | sed 's/  */ /g')

#some informations about the Mac
iboot_version=$(ioreg -l | grep firmware-abi | awk -F\" '{print $4}')
mac_model=$(sysctl -n hw.model)

# Memory information
# Convert pages to GB (page size is 4096 bytes)
page_size=$(pagesize)
total_mem=$(sysctl hw.memsize | awk '{print $2}')
total_mem_gb=$(echo "scale=2; $total_mem / 1024 / 1024 / 1024" | bc)

vm_stat_output=$(vm_stat)
pages_free=$(echo "$vm_stat_output" | grep "Pages free:" | awk '{print $3}' | tr -d '.')
pages_active=$(echo "$vm_stat_output" | grep "Pages active:" | awk '{print $3}' | tr -d '.')
pages_inactive=$(echo "$vm_stat_output" | grep "Pages inactive:" | awk '{print $3}' | tr -d '.')
pages_speculative=$(echo "$vm_stat_output" | grep "Pages speculative:" | awk '{print $3}' | tr -d '.')

used_mem=$(((pages_active + pages_inactive + pages_speculative) * page_size))
used_mem_gb=$(echo "scale=2; $used_mem / 1024 / 1024 / 1024" | bc)

# Init system (simplified)
init_system="launchd"

# Package managers
brew_count=0
port_count=0

if command -v brew >/dev/null 2>&1; then
    brew_count=$(brew list | wc -l | tr -d ' ')
fi

if command -v port >/dev/null 2>&1; then
    port_count=$(port list installed 2>/dev/null | wc -l | tr -d ' ')
fi

total_packages=$((brew_count + port_count))

# Output
printf "${dscolor}${dslogo1}${nc}$USER@$host\n"
printf "${dscolor}${dslogo2}${nc}OS     ${nc} $NAME $os_version\n"
printf "${dscolor}${dslogo3}${nc}Kernel ${nc} $kernel\n"
printf "${dscolor}${dslogo4}${nc}Uptime ${nc} $uptime\n"
printf "${dscolor}${dslogo5}${nc}Shell  ${nc} $shell\n"
printf "${dscolor}${dslogo6}${nc}CPU    ${nc} $cpu\n"
printf "${dscolor}${dslogo7}${nc}Memory ${nc} ${used_mem_gb}GB / ${total_mem_gb}GB\n"
printf "${dscolor}${dslogo8}${nc}Init   ${nc} $init_system\n"
printf "${dscolor}${dslogo9}${nc}Pkgs   ${nc} $total_packages (Brew: $brew_count, MacPorts: $port_count)\n"
if [ "$colorsoff" != 1 ]; then
    printf "${dscolor}${dslogo6}${nc}\033[0;31m● \033[0;32m● \033[0;33m● \033[0;34m● \033[0;35m● \033[0;36m● \033[0;37m●${nc}\n"
fi
