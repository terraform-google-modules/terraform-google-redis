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

METADATA_ROOT='http://metadata/computeMetadata/v1/instance/attributes'
cluster_name=$(curl -f -s -H Metadata-Flavor:Google $METADATA_ROOT/cluster-name)
cluster_members=$(curl -f -s -H Metadata-Flavor:Google $METADATA_ROOT/cluster-members)
bucket_name=$(curl -f -s -H Metadata-Flavor:Google $METADATA_ROOT/config-bucket)
gcs_root="gs://$bucket_name/$cluster_name"
ssl_dir="/etc/mysql/ssl"
log_dir="/var/log/garbd"

# Install Galera Arbitrator
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt install -y software-properties-common dirmngr
apt-key adv --recv-keys --no-tty --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.3/debian stretch main'
apt update -y
apt install -y mariadb-client galera-3 galera-arbitrator-3

service garb stop

mkdir -p "$ssl_dir"
gsutil cp "$gcs_root/garb.crt" "$ssl_dir/"
gsutil cp "$gcs_root/garb.pem" "$ssl_dir/"
gsutil cp "$gcs_root/ca.crt" "$ssl_dir/"
chmod -R 744 "$ssl_dir"
chmod 755 "$ssl_dir"
mkdir -p "$log_dir"
chmod 777 "$log_dir"

cat <<EOF > /etc/default/garb
GALERA_NODES="$cluster_members"
LOG_FILE="$log_dir/garbd.log"
GALERA_GROUP="$cluster_name"
GALERA_OPTIONS="socket.ssl_cert=$ssl_dir/garb.crt;socket.ssl_key=$ssl_dir/garb.pem;socket.ssl_ca=$ssl_dir/ca.crt;socket.ssl_cipher=AES128-SHA256"
EOF

e=$(service garb start >/dev/null 2>&1; echo $?)
let n=1
while [ "$e" != "0" ]; do
  sleep 30s
  e=$(service garb start >/dev/null 2>&1; echo $?)
  let n++
  [ $n -le 10 ] || exit 1
done

cat <<EOF > /etc/logrotate.d/garbd
/var/log/garbd/garbd*log {
  weekly
  rotate 150
  dateext
  compress
  copytruncate
  missingok 
}
EOF
