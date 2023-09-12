#set env vars
set -o allexport; source .env; set +o allexport;

mkdir -p ./storage/opensearch
chown -R 1000:1000 ./storage/opensearch

echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf && sysctl -p

apt install apache2-utils -y;

cat <<EOT > ./servers.json
{
    "Servers": {
        "1": {
            "Name": "local",
            "Group": "Servers",
            "Host": "172.17.0.1",
            "Port": 6754,
            "MaintenanceDB": "postgres",
            "SSLMode": "prefer",
            "Username": "postgres",
            "PassFile": "/pgpass"
        }
    }
}
EOT
