#set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 60s;

mkdir -p public
chown -R 991:991 public
mkdir -p public/system/media_attachments;
chown -R 991:991 public/system/media_attachments;
mkdir -p public/system/accounts;
chown -R 991:991 public/system/accounts;
mkdir -p public/system/site_uploads;
chown -R 991:991 public/system/site_uploads;
mkdir -p public/system/cache;
chown -R 991:991 public/system/cache;
docker-compose up -d;
sleeps 60s;
LOGIN=`echo "${ADMIN_EMAIL}" | awk -F "@" '{ print $1 }'`;
LOGIN=`echo $LOGIN | tr '.' '_'`
LOGIN=`echo $LOGIN | tr '-' '_'`
BCRYPT_PASSWORD=$(htpasswd -bnBC 10 "" ${ADMIN_PASSWORD} | tr -d ':\n');
docker-compose exec -T streaming sh -c "RAILS_ENV=production bin/tootctl accounts create ${LOGIN} --email [EMAIL] --confirmed --role Owner;"
docker exec -e PGPASSWORD=[APP_PASSWORD] db psql -d mastodon_production -U postgres -c "UPDATE "users" SET encrypted_password = '${BCRYPT_PASSWORD}' WHERE id = '1';"