#set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 60s;

OTP_SECRET=$(docker-compose run --rm web bundle exec rake secret);
SECRET_KEY_BASE=$(docker-compose run --rm web bundle exec rake secret);

cat << EOT >> ./.env

OTP_SECRET=${OTP_SECRET}
SECRET_KEY_BASE=${SECRET_KEY_BASE}

EOT

docker-compose run --rm web bundle exec rake mastodon:webpush:generate_vapid_key >> .env;
docker-compose run --rm web rails db:migrate;
docker-compose run --rm web rails assets:precompile;
docker-compose run --rm web bundle exec rails chewy:deploy;


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

sleep 60s;
LOGIN=`echo "${ADMIN_EMAIL}" | awk -F "@" '{ print $1 }'`;
LOGIN=`echo $LOGIN | tr '.' '_'`
LOGIN=`echo $LOGIN | tr '-' '_'`
BCRYPT_PASSWORD=$(htpasswd -bnBC 10 "" ${ADMIN_PASSWORD} | tr -d ':\n');

docker-compose exec -T streaming sh -c "RAILS_ENV=production bin/tootctl accounts create ${LOGIN} --email ${ADMIN_EMAIL} --confirmed --role Owner;"
docker-compose exec -T db psql -d mastodon_production -U postgres -c "UPDATE users SET encrypted_password = '${BCRYPT_PASSWORD}' WHERE id = '1';"

#fix streaming api
sed -i 's@listen 443 ssl http2;@listen 443 ssl http2;\n\n  location ^~ /api/v1/streaming {\n    proxy_pass http://172.17.0.1:4001;\n    proxy_set_header Host $http_host;\n  }\n\n@g' /opt/elestio/nginx/conf.d/${DOMAIN}.conf
#fix video views on ios
sed -i 's@location / {@location / {\n\n      proxy_force_ranges on;\n\n@g'  /opt/elestio/nginx/conf.d/${DOMAIN}.conf
#restart nginx
docker exec elestio-nginx nginx -s reload;