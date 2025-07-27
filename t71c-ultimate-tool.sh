#!/data/data/com.termux/files/usr/bin/bash

# Color Codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

check_api() {
  if command -v termux-telephony-deviceinfo >/dev/null 2>&1; then
    API_AVAILABLE=true
  else
    API_AVAILABLE=false
  fi
}

header() {
  clear
  echo -e "${CYAN}═════════════════════════════════════════════════════"
  echo -e "    ${GREEN}T71C Advanced SIM & Device Tool v3.0${CYAN}"
  echo -e "    Developed by AriYan Munna"
  echo -e "═════════════════════════════════════════════════════${NC}"
  if $API_AVAILABLE; then
    echo -e "${GREEN}✅ Termux:API detected. Full features enabled.${NC}\n"
  else
    echo -e "${YELLOW}⚠️ Termux:API NOT found. SIM info limited, some features disabled.${NC}\n"
  fi
}

pause() {
  echo -e "${YELLOW}Press Enter to continue...${NC}"
  read -r
}

sim_info() {
  echo -e "${CYAN}📶 SIM Info:${NC}"
  if $API_AVAILABLE; then
    termux-telephony-deviceinfo | jq || termux-telephony-deviceinfo
  else
    echo -e "${RED}Termux:API missing, limited SIM info from getprop:${NC}"
    echo "Operator Name: $(getprop gsm.operator.alpha)"
    echo "Network Type : $(getprop gsm.network.type)"
    echo "Country ISO  : $(getprop gsm.operator.iso-country)"
    echo "SIM State   : $(getprop gsm.sim.state)"
  fi
  pause
}

cell_info() {
  echo -e "${CYAN}🗼 Cell Tower Info:${NC}"
  if $API_AVAILABLE; then
    termux-telephony-cellinfo | jq || termux-telephony-cellinfo
  else
    echo -e "${RED}Termux:API missing, cannot show cell info.${NC}"
  fi
  pause
}

battery_info() {
  echo -e "${CYAN}🔋 Battery Info:${NC}"
  if $API_AVAILABLE; then
    termux-battery-status | jq || termux-battery-status
  else
    echo -e "${RED}Termux:API missing, limited battery info via dumpsys:${NC}"
    dumpsys battery | grep -E "level|status|health|temperature"
  fi
  pause
}

device_info() {
  echo -e "${CYAN}📱 Device Info:${NC}"
  echo "Brand       : $(getprop ro.product.brand)"
  echo "Model       : $(getprop ro.product.model)"
  echo "Android Ver : $(getprop ro.build.version.release)"
  echo "CPU Arch    : $(getprop ro.product.cpu.abi)"
  echo "Manufacturer: $(getprop ro.product.manufacturer)"
  pause
}

storage_info() {
  echo -e "${CYAN}💾 Storage Info:${NC}"
  df -h /
  pause
}

network_info() {
  echo -e "${CYAN}🌐 Network Info:${NC}"
  ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print "WiFi IP: "$2}'
  ip addr show rmnet_data0 2>/dev/null | grep 'inet ' | awk '{print "Mobile IP: "$2}'
  ping -c 2 google.com >/dev/null && echo "Internet: Connected" || echo "Internet: Disconnected"
  pause
}

volte_check() {
  echo -e "${CYAN}📞 VoLTE Support:${NC}"
  getprop | grep -i volte | head -5 || echo "No VoLTE info found"
  pause
}

root_check() {
  echo -e "${CYAN}🔐 Root Status:${NC}"
  if [ "$(id -u)" -eq 0 ]; then
    echo "Root Access: Yes"
  else
    echo "Root Access: No"
  fi
  pause
}

export_report() {
  file="t71c_report_$(date +%F_%H-%M-%S).txt"
  echo -e "${CYAN}Exporting report to $file${NC}"
  {
    echo "T71C Advanced SIM & Device Tool Report"
    echo "Generated: $(date)"
    echo
    echo "SIM Info:"
    if $API_AVAILABLE; then
      termux-telephony-deviceinfo || echo "N/A"
    else
      echo "Operator Name: $(getprop gsm.operator.alpha)"
      echo "Network Type : $(getprop gsm.network.type)"
      echo "Country ISO  : $(getprop gsm.operator.iso-country)"
      echo "SIM State    : $(getprop gsm.sim.state)"
    fi
    echo
    echo "Cell Tower Info:"
    if $API_AVAILABLE; then
      termux-telephony-cellinfo || echo "N/A"
    else
      echo "Not available without Termux:API"
    fi
    echo
    echo "Battery Info:"
    if $API_AVAILABLE; then
      termux-battery-status || dumpsys battery | grep -E "level|status|health|temperature"
    else
      dumpsys battery | grep -E "level|status|health|temperature"
    fi
    echo
    echo "Device Info:"
    echo "Brand       : $(getprop ro.product.brand)"
    echo "Model       : $(getprop ro.product.model)"
    echo "Android Ver : $(getprop ro.build.version.release)"
    echo "CPU Arch    : $(getprop ro.product.cpu.abi)"
    echo "Manufacturer: $(getprop ro.product.manufacturer)"
    echo
    echo "Storage Info:"
    df -h /
    echo
    echo "Network Info:"
    ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print "WiFi IP: "$2}'
    ip addr show rmnet_data0 2>/dev/null | grep 'inet ' | awk '{print "Mobile IP: "$2}'
    ping -c 2 google.com >/dev/null && echo "Internet: Connected" || echo "Internet: Disconnected"
    echo
    echo "VoLTE Support:"
    getprop | grep -i volte | head -5 || echo "No VoLTE info found"
    echo
    echo "Root Status:"
    if [ "$(id -u)" -eq 0 ]; then
      echo "Root Access: Yes"
    else
      echo "Root Access: No"
    fi
  } > "$file"
  echo -e "${GREEN}Report exported as $file${NC}"
  pause
}

main_menu() {
  check_api
  while true; do
    header
    echo "1) SIM Info"
    echo "2) Cell Tower Info"
    echo "3) Battery Info"
    echo "4) Device Info"
    echo "5) Storage Info"
    echo "6) Network Info"
    echo "7) VoLTE Support Check"
    echo "8) Root Status"
    echo "9) Export Full Report"
    echo "0) Exit"
    echo -n "Select option: "
    read -r choice
    case $choice in
      1) sim_info ;;
      2) cell_info ;;
      3) battery_info ;;
      4) device_info ;;
      5) storage_info ;;
      6) network_info ;;
      7) volte_check ;;
      8) root_check ;;
      9) export_report ;;
      0) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
      *) echo -e "${RED}Invalid choice! Try again.${NC}" ; pause ;;
    esac
  done
}

main_menu
