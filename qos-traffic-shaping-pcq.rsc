# -------------------------------------------------------------------------
# SCRIPT: Advanced QoS with PCQ (Traffic Shaping)
# DESCRIPTION: Prioritizes critical traffic (DNS, VoIP, Gaming) over bulk 
#              downloads/web browsing using PCQ queues.
# AUTHOR: Victor Augusto (Adapted)
# -------------------------------------------------------------------------

# 1. Define PCQ Types for Upload/Download
/queue type
add kind=pcq name=DOWNLOAD-PCQ pcq-classifier=dst-address pcq-dst-address6-mask=64 pcq-src-address6-mask=64
add kind=pcq name=UPLOAD-PCQ pcq-classifier=src-address pcq-dst-address6-mask=64 pcq-src-address6-mask=64

# 2. Create Parent Queues
/queue tree
add name="Total_Download" parent=ether2 queue=DOWNLOAD-PCQ
add name="Total_Upload" parent=ether1 queue=UPLOAD-PCQ

# 3. Prioritization Rules (1 = Highest, 8 = Lowest)

# Priority 1: ICMP (Ping/Latency check)
add name="ICMP_Down" packet-mark=icmp parent="Total_Download" priority=1 queue=DOWNLOAD-PCQ
add name="ICMP_Up" packet-mark=icmp parent="Total_Upload" priority=1 queue=UPLOAD-PCQ

# Priority 3: DNS & SpeedTest (Critical Infrastructure)
add name="DNS_Up" packet-mark=dns parent="Total_Upload" priority=3 queue=UPLOAD-PCQ
add name="DNS_Down" packet-mark=dns parent="Total_Download" priority=3 queue=DOWNLOAD-PCQ

# Priority 5: VoIP & Gaming (WhatsApp Calls, Fortnite - Real Time App)
add name="VoIP_Gaming_Up" packet-mark=realtime_apps parent="Total_Upload" priority=5 queue=UPLOAD-PCQ
add name="VoIP_Gaming_Down" packet-mark=realtime_apps parent="Total_Download" priority=5 queue=DOWNLOAD-PCQ

# Priority 8: General Web/Rest (Bulk Traffic)
add name="General_Web_Down" packet-mark=web parent="Total_Download" priority=8 queue=DOWNLOAD-PCQ
add name="General_Web_Up" packet-mark=web parent="Total_Upload" priority=8 queue=UPLOAD-PCQ

# 4. Mangle Rules (Marking Connections & Packets)
/ip firewall mangle

# Mark ICMP
add action=mark-connection chain=prerouting comment="Traffic: ICMP" new-connection-mark=icmp_conn protocol=icmp
add action=mark-packet chain=prerouting connection-mark=icmp_conn new-packet-mark=icmp passthrough=no

# Mark DNS
add action=mark-connection chain=prerouting comment="Traffic: DNS" new-connection-mark=dns_conn port=53 protocol=udp
add action=mark-packet chain=prerouting connection-mark=dns_conn new-packet-mark=dns passthrough=no

# Mark Real-Time (WhatsApp Calls / Gaming Ports)
add action=mark-connection chain=prerouting comment="VoIP & Gaming" new-connection-mark=realtime_conn passthrough=yes port=3478,5222,5060 protocol=udp
add action=mark-packet chain=prerouting connection-mark=realtime_conn new-packet-mark=realtime_apps passthrough=no

# Mark Web (HTTP/HTTPS)
add action=mark-connection chain=prerouting comment="Web Traffic" new-connection-mark=web_conn port=80,443 protocol=tcp
add action=mark-packet chain=prerouting connection-mark=web_conn new-packet-mark=web passthrough=no
