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

# Variables
ip=`hostname -i`

METADATA_ROOT='http://metadata/computeMetadata/v1/instance/attributes'
id=$(curl -f -s -H Metadata-Flavor:Google $METADATA_ROOT/node-id)
cluster_name=$(curl -f -s -H Metadata-Flavor:Google $METADATA_ROOT/cluster-name)
bucket_name=$(curl -f -s -H Metadata-Flavor:Google $METADATA_ROOT/config-bucket)
cluster_members=$(curl -f -s -H Metadata-Flavor:Google $METADATA_ROOT/cluster-members)
databases=$(curl -f -s -H Metadata-Flavor:Google $METADATA_ROOT/databases)
create_time=$(curl -f -s -H Metadata-Flavor:Google $METADATA_ROOT/create-time)

gcs_root="gs://$bucket_name/$cluster_name"
collectd_conf="/opt/stackdriver/collectd/etc/collectd.d/mysql.conf"
ssl_dir="/etc/mysql/ssl"
let offset=1+$id

# Install MariaDB
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt install -y software-properties-common dirmngr
apt-key adv --recv-keys --no-tty --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.3/debian stretch main'
apt update -y
debconf-set-selections <<< 'mariadb-server-10.3 mysql-server/root_password password ${pass}'
debconf-set-selections <<< 'mariadb-server-10.3 mysql-server/root_password_again password ${pass}'
apt install -y mariadb-server mariadb-client galera-3

service mysql stop

cat <<EOF > /etc/mysql/mariadb.conf.d/galera.cnf
[client]
port     = 3306
socket   = /var/run/mysqld/mysqld.sock
ssl-ca   = $ssl_dir/ca.crt
ssl-cert = $ssl_dir/$id.crt
ssl-key  = $ssl_dir/$id.pem

[mysql]
default-character-set = utf8

[mysqld]
server_id                = $id
report_host              = $id
skip-networking          = 0
skip-bind-address
log_bin                  = /var/log/mysql/mariadb-bin
log_bin_index            = /var/log/mysql/mariadb-bin.index
relay_log                = /var/log/mysql/relay-bin
relay_log_index          = /var/log/mysql/relay-bin.index
collation-server         = utf8_general_ci
character-set-server     = utf8
binlog_format            = ROW
default-storage-engine   = innodb
innodb_autoinc_lock_mode = 2
query_cache_size         = 0
query_cache_type         = 0
innodb_flush_log_at_trx_commit = 0
innodb_buffer_pool_size  = 256M
auto_increment_increment = 4
auto_increment_offset    = $offset
ssl-ca                   = $ssl_dir/ca.crt
ssl-cert                 = $ssl_dir/$id.crt
ssl-key                  = $ssl_dir/$id.pem
wsrep_provider           = "/usr/lib/galera/libgalera_smm.so"
wsrep_provider_options   ="socket.ssl_key=$ssl_dir/$id.pem;socket.ssl_cert=$ssl_dir/$id.crt;socket.ssl_ca=$ssl_dir/ca.crt;socket.ssl_cipher=AES128-SHA256"
wsrep_cluster_name       = "$cluster_name"
wsrep_cluster_address    = "gcomm://$cluster_members"
wsrep_sst_method         = rsync
wsrep_on                 = ON
wsrep_node_address       = "$ip"
wsrep_node_name          = "$id"
explicit_defaults_for_timestamp = 1
EOF

mkdir -p "$ssl_dir"
gsutil cp "$gcs_root/ca.crt" "$ssl_dir/"
gsutil cp "$gcs_root/$id.crt" "$ssl_dir/"
gsutil cp "$gcs_root/$id.pem" "$ssl_dir/"

e=$(service mysql start >/dev/null 2>&1; echo $?)

# Only bootstrap if cluster was created less than 15 minutes ago
let bootstrap_period=$(date --date="$create_time" +%s)+900
if [ $e -ne 0 ]; then
  if [ $(date +%s) -lt $bootstrap_period ] && [ "$id" == "0" ]; then  
    service mysql stop
    systemctl set-environment _WSREP_NEW_CLUSTER='--wsrep-new-cluster'
    service mysql start
    systemctl set-environment _WSREP_NEW_CLUSTER=''
    mysql -uroot -p${pass} -B <<EOF
create user if not exists 'stats'@'localhost' identified by '${statspass}';
grant select on sys.* to 'stats'@'localhost';
grant select on performance_schema.* to 'stats'@'localhost';
EOF
    for db in $databases; do
      mysql -uroot -p${pass} -B -e "create database if not exists $db;"
    done
  else
    sleep 60s
    service mysql start
  fi
fi

mysql -uroot -p${pass} -N -B -e "show status like 'wsrep%';"

# StackDriver Agent
curl -sSO "https://dl.google.com/cloudagents/install-monitoring-agent.sh"
/bin/bash install-monitoring-agent.sh
apt install -y libmysqlclient20

# Write collectd configuration
cat <<EOF>> $collectd_conf
LoadPlugin mysql
<Plugin "mysql">
EOF

for db in $databases; do
  cat <<EOF>> $collectd_conf
    <Database "$db">
        Host "localhost"
        Port 3306
        User "stats"
        Password "${statspass}"
        MasterStats true
        SlaveStats true
    </Database>
EOF
done

cat <<EOF>> $collectd_conf
</Plugin>
EOF

service stackdriver-agent restart
