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

echo 511 > /proc/sys/net/core/somaxconn
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
sysctl vm.overcommit_memory=1

export DEBIAN_FRONTEND=noninteractive
echo 'deb http://packages.cloud.google.com/apt google-cloud-monitoring-stretch main' > /etc/apt/sources.list.d/google-cloud-monitoring.list
apt update -y
apt install -y stackdriver-agent libhiredis0.13
apt install -y redis-sentinel redis-server
service redis stop
service redis-sentinel stop

cat <<EOF > /etc/redis/sentinel.conf
bind 0.0.0.0
port 26379
dir "/var/lib/redis"
daemonize yes
pidfile "/var/run/redis/redis-sentinel.pid"
logfile "/var/log/redis/redis-sentinel.log"
sentinel monitor mymaster ${master} 6379 2
sentinel auth-pass mymaster ${pass}
sentinel down-after-milliseconds mymaster 16000
EOF

cat <<EOF > /etc/redis/redis.conf
bind 0.0.0.0
port 6379
masterauth ${pass}
requirepass ${pass}
dir /var/lib/redis
pidfile /var/run/redis/redis-server.pid
logfile /var/log/redis/redis-server.log
dbfilename dump.rdb
appendfilename "appendonly.aof"
protected-mode yes
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize yes
supervised no
loglevel notice
databases 16
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
appendonly yes
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
min-slaves-to-write 1
min-slaves-max-lag 10
rename-command FLUSHDB ""
rename-command FLUSHALL ""
EOF

myip=$(/sbin/ifconfig | grep -m 1 'inet ' | awk {'print $2'})
[ '${master}' == "$myip" ] || cat <<EOF >> /etc/redis/redis.conf
slaveof ${master} 6379
EOF

cat <<EOF > /etc/logrotate.d/redis
/var/log/redis/redis-server*log {
  weekly
  rotate 150
  dateext
  compress
  copytruncate
  missingok
}

/var/log/redis/redis-sentinel*log {
  weekly
  rotate 150
  dateext
  compress
  copytruncate
  missingok
}
EOF

# StackDriver Agent with Redis plugin
cat <<EOF > /opt/stackdriver/collectd/etc/collectd.d/redis.conf
LoadPlugin redis
<Plugin "redis">
    <Node "mynode">
        Host "localhost"
        Port "6379"
        Password "${pass}"
        Timeout 2000
    </Node>
</Plugin>
EOF
service stackdriver-agent restart
service redis restart
service redis-sentinel restart
