#!/bin/bash
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
set -x

export DEBIAN_FRONTEND=noninteractive
apt update -y
apt install -y nftables
systemctl enable nftables.service

cat << EOF >> /etc/sysctl.conf
net.core.wmem_max=12582912
net.core.rmem_max=12582912
net.ipv4.tcp_rmem= 10240 262144 12582912
net.ipv4.tcp_wmem= 10240 262144 12582912
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.ip_forward=1
net.core.netdev_max_backlog = 10000
EOF

sysctl -p

systemctl restart nftables

nft add table    nat
nft add chain    nat    post { type nat hook postrouting priority 0 \; }
nft add chain    nat    pre  { type nat hook prerouting priority 0  \; } 
nft add  rule    nat    post masquerade
nft add  rule ip nat    pre  tcp dport 443 ip saddr ${client_ip_range} dnat 199.36.153.4:443
# Health Check IP Ranges
nft add  rule ip nat    pre  tcp dport 443 ip saddr 35.191.0.0/16 dnat 199.36.153.4:443
nft add  rule ip nat    pre  tcp dport 443 ip saddr 130.211.0.0/22 dnat 199.36.153.4:443
