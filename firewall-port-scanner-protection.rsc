# -------------------------------------------------------------------------
# SCRIPT: Port Scanner Detection & Blocking
# DESCRIPTION: Identifies NMAP scans and brute-force attempts using TCP Flags 
#              logic and adds attackers to a dynamic blacklist for 2 weeks.
# AUTHOR: Victor Augusto (Adapted)
# -------------------------------------------------------------------------

/ip firewall filter

# 1. Add Scanners to Address List based on TCP Flags signatures

# NMAP FIN Stealth scan
add action=add-src-to-address-list address-list="port_scanners" \
    address-list-timeout=2w chain=input comment="NMAP FIN Stealth scan" \
    protocol=tcp tcp-flags=fin,!syn,!rst,!psh,!ack,!urg

# SYN/FIN scan
add action=add-src-to-address-list address-list="port_scanners" \
    address-list-timeout=2w chain=input comment="SYN/FIN scan" protocol=tcp \
    tcp-flags=fin,syn

# SYN/RST scan
add action=add-src-to-address-list address-list="port_scanners" \
    address-list-timeout=2w chain=input comment="SYN/RST scan" protocol=tcp \
    tcp-flags=syn,rst

# FIN/PSH/URG scan (Xmas Scan)
add action=add-src-to-address-list address-list="port_scanners" \
    address-list-timeout=2w chain=input comment="FIN/PSH/URG scan" protocol=\
    tcp tcp-flags=fin,psh,urg,!syn,!rst,!ack

# ALL/ALL scan
add action=add-src-to-address-list address-list="port_scanners" \
    address-list-timeout=2w chain=input comment="ALL/ALL scan" protocol=tcp \
    tcp-flags=fin,syn,rst,psh,ack,urg

# NMAP NULL scan
add action=add-src-to-address-list address-list="port_scanners" \
    address-list-timeout=2w chain=input comment="NMAP NULL scan" protocol=tcp \
    tcp-flags=!fin,!syn,!rst,!psh,!ack,!urg

# 2. DROP Rule
add action=drop chain=input comment="DROP Port Scanners" \
    src-address-list="port_scanners"

# 3. Protect Critical Ports (SSH/FTP) from Brute Force
add action=drop chain=input comment="Drop SSH Brute Force" dst-port=22 \
    protocol=tcp src-address-list=ssh_blacklist

add action=add-src-to-address-list address-list=ssh_blacklist \
    address-list-timeout=1d chain=input connection-state=new dst-port=22 \
    protocol=tcp src-address-list=ssh_stage3

# (Stage logic continues...)
