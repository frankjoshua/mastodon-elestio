#set env vars
set -o allexport; source .env; set +o allexport;

mkdir -p ./storage/opensearch
chmod 777 ./storage/opensearch