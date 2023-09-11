# Mastodon CI/CD pipeline

<a href="https://dash.elest.io/deploy?source=cicd&social=dockerCompose&url=https://github.com/elestio-examples/mastodon"><img src="deploy-on-elestio.png" alt="Deploy on Elest.io" width="180px" /></a>

Deploy Mastodon server with CI/CD on Elestio

<img src="mastodon.jpg" style='width: 100%;'/>
<br/>
<br/>

# Configuration

To deploy Mastodon, 2 CPUs/8GB RAM or more are recommended.

# Once deployed ...

You can open Mastodon UI here:

    URL: https://[CI_CD_DOMAIN]
    email: [ADMIN_EMAIL]
    password: [ADMIN_PASSWORD]

You can open pgAdmin web UI here:

    URL: https://[CI_CD_DOMAIN]:6443
    email: [ADMIN_EMAIL]
    password: [ADMIN_PASSWORD]

You can open Opensearch Dashboard here:

    URL: https://[CI_CD_DOMAIN]:5443
    email: root
    password: [ADMIN_PASSWORD]

# Custom domain instructions (IMPORTANT)

By default we setup a CNAME on elestio.app domain, but probably you will want to have your own domain.

**_Step1:_** add your domain in Elestio dashboard as explained here:

    https://docs.elest.io/books/security/page/custom-domain-and-automated-encryption-ssltls

**_Step2:_** update the env vars to indicate your custom domain
Open Elestio dashboard > Service overview > click on UPDATE CONFIG button > Env tab
there update `LOCAL_DOMAIN`, `ALTERNATE_DOMAINS` & `DOMAIN` with your real domain
In the same tab, remove `OTP_SECRET` and `SECRET_KEY_BASE` variable name and values.

**_Step3:_** you must reset the Mastodon instance , you can do that with those commands, connect over SSH and run this:

    cd /opt/app;
    docker-compose down;
    rm -rf ./public;
    rm -rf ./storage;
    ./scripts/preInstall.sh
    docker-compose up -d
    ./scripts/postInstall.sh

You will start over with a fresh instance of Mastodon directly configured with the correct custom domain name and federation will work as expected
