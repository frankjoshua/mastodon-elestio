<a href="https://elest.io">
  <img src="https://elest.io/images/elestio.svg" alt="elest.io" width="150" height="75">
</a>

[![Discord](https://img.shields.io/static/v1.svg?logo=discord&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=Discord&message=community)](https://discord.gg/4T4JGaMYrD "Get instant assistance and engage in live discussions with both the community and team through our chat feature.")
[![Elestio examples](https://img.shields.io/static/v1.svg?logo=github&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=github&message=open%20source)](https://github.com/elestio-examples "Access the source code for all our repositories by viewing them.")
[![Blog](https://img.shields.io/static/v1.svg?color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=elest.io&message=Blog)](https://blog.elest.io "Latest news about elestio, open source software, and DevOps techniques.")

# Mastodon, verified and packaged by Elestio

[Mastodon](https://github.com/mastodon/mastodon) is a free fediverse, open-source social network server with OpenSearch for indexing.

<img src="https://github.com/elestio-examples/mastodon/raw/main/mastodon.jpg" alt="mastodon" width="800">

Deploy a <a target="_blank" href="https://elest.io/open-source/mastodon">fully managed MastoDon</a> on <a target="_blank" href="https://elest.io/">elest.io</a> is a free, open-source social network server where users can follow friends and discover new ones. On Mastodon, users can publish anything they want: links, pictures, text, video. It comes with OpenSearch for indexing.

[![deploy](https://github.com/elestio-examples/mastodon/raw/main/mastodon.jpg)](https://dash.elest.io/deploy?source=cicd&social=dockerCompose&url=https://github.com/elestio-examples/mastodon)

# Why use Elestio images?

- Elestio stays in sync with updates from the original source and quickly releases new versions of this image through our automated processes.
- Elestio images provide timely access to the most recent bug fixes and features.
- Our team performs quality control checks to ensure the products we release meet our high standards.

# Usage

## Git clone

You can deploy it easily with the following command:

    git clone https://github.com/elestio-examples/mastodon.git

Copy the .env file from tests folder to the project directory

    cp ./tests/.env ./.env

Edit the .env file with your own values.

Create data folders with correct permissions

    mkdir -p ./storage/postgres;
    chown -R 1001:1001 ./storage/postgres;

    mkdir -p ./storage/redis;
    chown -R 1001:1001 ./storage/redis;

    mkdir -p ./storage/opensearch;
    chown -R 1001:1001 ./storage/opensearch;

    mkdir -p ./public/system ;
    chown -R 1001:1001 ./public/system;

Run the project with the following command

    docker-compose up -d

You can access the Web UI at: `http://your-domain:6835`

## Docker-compose

Here are some example snippets to help you get started creating a container.

    version: "3.3"
    services:
    db:
        restart: always
        image: elestio/postgres:15
        shm_size: 256mb
        container_name: db
        volumes:
        - ./storage/postgres:/var/lib/postgresql/data
        ports:
        - 172.17.0.1:8290:5432
        environment:
        - "POSTGRES_HOST_AUTH_METHOD=trust"
        - POSTGRES_USER=postgres
        - POSTGRES_PASSWORD=${DB_PASS}
        - POSTGRES_DB=mastodon_production

    redis:
        restart: always
        image: elestio/redis:7.0
        container_name: redis
        volumes:
        - ./storage/redis:/data

    opensearch:
        image: opensearchproject/opensearch:${SOFTWARE_VERSION_TAG}
        restart: always
        environment:
        - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m -Des.enforce.bootstrap.checks=true"
        - "bootstrap.memory_lock=true"
        - "cluster.name=opensearch-mastodon"
        - "discovery.type=single-node"
        - "thread_pool.write.queue_size=1000"
        - "node.name=opensearch"
        - "DISABLE_INSTALL_DEMO_CONFIG=true"
        - "DISABLE_SECURITY_PLUGIN=true"
        ulimits:
        memlock:
            soft: -1
            hard: -1
        nofile:
            soft: 65536
            hard: 65536
        volumes:
        - ./storage/opensearch:/usr/share/opensearch/data
        ports:
        - 172.17.0.1:9280:9200

    web:
        image: elestio4test/mastodon:${SOFTWARE_VERSION_TAG}
        restart: always
        env_file: ./.env
        command: bash -c "rm -f /mastodon/tmp/pids/server.pid; bundle exec rails s -p 3000"
        ports:
        - "172.17.0.1:7834:3000"
        depends_on:
        - db
        - redis
        - opensearch
        volumes:
        - ./public/system:/mastodon/public/system

    streaming:
        image: elestio4test/mastodon:${SOFTWARE_VERSION_TAG}
        restart: always
        env_file: ./.env
        command: node ./streaming
        ports:
        - "172.17.0.1:8834:4000"
        depends_on:
        - db
        - redis

    sidekiq:
        image: elestio4test/mastodon:${SOFTWARE_VERSION_TAG}
        restart: always
        env_file: ./.env
        command: bundle exec sidekiq
        depends_on:
        - db
        - redis
        volumes:
        - ./public/system:/mastodon/public/system

    pgadmin4:
        image: dpage/pgadmin4:${SOFTWARE_VERSION_TAG}
        restart: always
        environment:
        PGADMIN_DEFAULT_EMAIL: ${ADMIN_EMAIL}
        PGADMIN_DEFAULT_PASSWORD: ${ADMIN_PASSWORD}
        PGADMIN_LISTEN_PORT: 8080
        ports:
        - "172.17.0.1:8367:8080"
        volumes:
        - ./servers.json:/pgadmin4/servers.json

    opensearch-dashboards:
        image: opensearchproject/opensearch-dashboards:${SOFTWARE_VERSION_TAG}
        restart: always
        ports:
        - 172.17.0.1:6835:5601
        expose:
        - "5601"
        environment:
        OPENSEARCH_HOSTS: '["http://opensearch:9200"]'
        DISABLE_SECURITY_DASHBOARDS_PLUGIN: "true"


# Maintenance

## Logging

The Elestio MastoDon Docker image sends the container logs to stdout. To view the logs, you can use the following command:

    docker-compose logs -f

To stop the stack you can use the following command:

    docker-compose down

## Backup and Restore with Docker Compose

To make backup and restore operations easier, we are using folder volume mounts. You can simply stop your stack with docker-compose down, then backup all the files and subfolders in the folder near the docker-compose.yml file.

Creating a ZIP Archive
For example, if you want to create a ZIP archive, navigate to the folder where you have your docker-compose.yml file and use this command:

    zip -r myarchive.zip .

Restoring from ZIP Archive
To restore from a ZIP archive, unzip the archive into the original folder using the following command:

    unzip myarchive.zip -d /path/to/original/folder

Starting Your Stack
Once your backup is complete, you can start your stack again with the following command:

    docker-compose up -d

That's it! With these simple steps, you can easily backup and restore your data volumes using Docker Compose.

# Links

- <a target="_blank" href="https://github.com/mastodon/mastodon">MastoDon Github repository</a>

- <a target="_blank" href="https://docs.joinmastodon.org/">MastoDon documentation</a>

- <a target="_blank" href="https://github.com/elestio-examples/mastodon">Elestio/MastoDon Github repository</a>
