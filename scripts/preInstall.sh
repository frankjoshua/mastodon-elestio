#set env vars
set -o allexport; source .env; set +o allexport;

OTP_SECRET=$(docker-compose run --rm web bundle exec rake secret);
SECRET_KEY_BASE=$(docker-compose run --rm web bundle exec rake secret);

cat << EOT >> ./.env

OTP_SECRET=${OTP_SECRET}
SECRET_KEY_BASE=${SECRET_KEY_BASE}

EOT

docker-compose run --rm web bundle exec rake mastodon:webpush:generate_vapid_key >> .env;
docker-compose run --rm web rails db:migrate;
docker-compose run --rm web rails assets:precompile;