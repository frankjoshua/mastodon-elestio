#set env vars
set -o allexport; source .env; set +o allexport;

mkdir -p ./storage/opensearch
chown -R 1000:1000 ./storage/opensearch