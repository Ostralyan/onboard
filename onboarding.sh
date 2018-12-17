#!/usr/bin/env bash

# Prompt user to manually install java
echo -n "Checking if java installed... ";

[ ! -z $(which java) ] && JAVA_RUNNING=true || JAVA_RUNNING=false
if [ "$JAVA_RUNNING" = false ]; then

    if [ "$OS" == "MAC" ]; then
        echo "$JAVA_RUNNING"
        echo "Installing Java..."
        brew tap caskroom/versions
        brew cask install java8
    fi
fi
echo "Success";

WHICH_DOCKER=$(which docker)

echo -n "Checking if docker installed... ";

$DOCKER_CMD ps && DOCKER_RUNNING=true || DOCKER_RUNNING=false

while [ "$DOCKER_RUNNING" = "false" ]; do
    echo "Manually install docker here - https://www.docker.com/community-edition"
    read -p "Make sure to run the docker application [y]" answer
    case "$answer" in
        [Yy]* ) $DOCKER_CMD ps && DOCKER_RUNNING=true || DOCKER_RUNNING=false;;
        * ) echo "Please answer y when you have manually installed and started docker - https://www.docker.com/community-edition";;
    esac
done

echo "Success";

# Install nvm
echo -n "Checking if nvm installed... "
if [ ! -d "$HOME/.nvm" ]; then
  echo -e "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
fi
echo "Success";

# Sourcing nvm to make available in bash_profile
# https://unix.stackexchange.com/questions/184508/nvm-command-not-available-in-bash-script
source ~/.nvm/nvm.sh

# Install node version 8.9.3
nvm install v8.9.3

# Making node version default
nvm alias default v8.9.3

# high open files limit for gulp
# echo "ulimit -n 65536 65536" >> ~/.bash_profile

###########################################################################
## These are the things that can be done prior to the engineer's arrival ##
###########################################################################

while true; do
    read -p "Is the developer ready with their ssh git keys created? [y/N]" answer
    case "$answer" in
        [Yy]* ) break;;
        [Nn]* ) exit 1; break;;
        * ) echo "Please answer yes or no to exit.";;
    esac
done

# S3 download of keys will fail if they don't have their AWS credentials set up
# https://honestbuildings.atlassian.net/wiki/spaces/HE/pages/3112961/On-Boarding+Steps
while true; do
    read -p "Is the developer ready with their aws credentials? [y/N]" answer
    case "$answer" in
        [Yy]* ) break;;
        [Nn]* ) echo "Please follow the on-boarding steps to configure your aws credentials"; exit 1; break;;
        * ) echo "Please answer yes or no to exit.";;
    esac
done

echo "Downloading Nginx SSL Local Certificates"

aws s3 cp s3://hb-devops-dev/nginx_ssl/fullchain1.pem /usr/local/etc/nginx/fullchain1.pem ;
aws s3 cp s3://hb-devops-dev/nginx_ssl/privkey1.pem /usr/local/etc/nginx/privkey1.pem ;
if [ $? -ne 0 ]; then
  echo -e "${RED}Pulling down Nginx SSL Local Certificates failed:";
  echo -e "Please make sure you followed the documentation on setting up your AWS credentials."
  echo -e "The script will need to be re-run.  If it continues to fail please contact the HB DevOps Team"
  echo -e "${NC}";
  exit 1;
fi

read -r -d '' NON_INTELLIJ_NGINX << EOM
# docker local www + api
server {
    listen 8080;
    server_name local.honestbuildings.com;
    rewrite ^/(.*)$ https://$host:8443/$1 permanent;
}

server {
    listen 8443 ssl;
    server_name local.honestbuildings.com;
    root $DEV_DIR/hbng/angularjs/dist;

    client_max_body_size    100m;
    client_body_buffer_size 1024k;
    client_header_buffer_size 2k;

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt { access_log off; log_not_found off; }

    ssl_certificate /usr/local/etc/nginx/fullchain1.pem;
    ssl_certificate_key /usr/local/etc/nginx/privkey1.pem;

    location ~ /(\.ht|\.git|\.svn) {
        deny  all;
    }

    location / {
        index index.html;
        try_files \$uri \$uri/ \$uri/index.html @catchall;
    }

    #location ~ ^/3.0/(.*) {
    #    rewrite ^/3.0/(.*)$ /\$1 break;
    #    proxy_pass http://localhost:8080;
    #}

    location @catchall{
        proxy_pass http://localhost:8888;
    }
}
EOM

read -r -d '' INTELLIJ_NGINX << EOM
# docker local www + api
server {
    listen 8080;
    server_name local.honestbuildings.com;
    rewrite ^/(.*)$ https://$host:8443/$1 permanent;
}

server {
    listen 8443 ssl;
    server_name local.honestbuildings.com;
    root $DEV_DIR/hbng/angularjs/dist;

    client_max_body_size    100m;
    client_body_buffer_size 1024k;
    client_header_buffer_size 2k;

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt { access_log off; log_not_found off; }

    ssl_certificate /usr/local/etc/nginx/fullchain1.pem;
    ssl_certificate_key /usr/local/etc/nginx/privkey1.pem;

    location ~ /(\.ht|\.git|\.svn) {
        deny  all;
    }

    location / {
        index index.html;
        try_files \$uri \$uri/ \$uri/index.html @catchall;
    }

    location ~ ^/3.0/(.*) {
        rewrite ^/3.0/(.*)$ /\$1 break;
        proxy_pass http://localhost:8080;
    }

    location @catchall{
        proxy_pass http://localhost:8888;
    }
}
EOM

# Prompt if you are an IntelliJ user
while true; do
    read -p " Do you use IntelliJ to run the changelog service? - Answer N if you do not have Intellij setup [y/N]" yn
    case $yn in
        [Yy]* ) NGINX_SETTINGS="$INTELLIJ_NGINX"; break;;
        [Nn]* ) NGINX_SETTINGS="$NON_INTELLIJ_NGINX"; break;;
        * ) echo "Please answer yes or no. Answer no if you don't have Intellij setup";;
    esac
done

echo -n "Checking if hbng repo is cloned... ";

# Check if hbng repos exists
if [ ! -d "$DEV_DIR"/hbng ]; then
  git clone git@github.com:honestbuildings/hbng.git "$DEV_DIR"/hbng
  if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to clone repo. Please make sure your ssh keys are setup for github:";
    echo "- https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/";
    echo "- https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/";
    echo -e "${NC}";
    exit 1;
  fi
fi
echo "Success";

# I have seen git clone fail on ubuntu because of permission issues
# The permissions should be this way across operating systems
chmod 755 "$DEV_DIR"/hbng

echo "Please create a quay.io account using your github account.";
echo "MAC OSX - Once your account is created run \"docker login quay.io\" and enter your username and password.";
echo "Encrypted command line password will be in quay.io > account settings > encrypted password"

while true; do
  read -p "Have the above steps been completed?? [y/n]" yn
  case "$yn" in
    [Yy]* ) echo "Great! Here we go..."; break;;
    [Nn]* ) echo "The next step may fail..."; break;;
    * ) echo "Please enter yes or no to continue.";;
  esac
done

#Setup cron job to automatically cycle keys every 3 months
EXISTING_CRONS=$(crontab -l | grep setup-rotate-keys)
if [ -z "$EXISTING_CRONS" ];then
    crontab -l | { cat; echo "0 0 1 * * ~/dev/hbng/aws/setup-rotate-keys.sh"; } | crontab -
fi

# Pull docker images
$DOCKER_CMD pull quay.io/honestbuildings/hb_mysql:2018-12-05 &&
$DOCKER_CMD pull quay.io/honestbuildings/hb_elasticsearch:2018-12-05 &&
$DOCKER_CMD pull quay.io/honestbuildings/hb_mailhog:latest &&
$DOCKER_CMD pull quay.io/honestbuildings/hb_electron_render_service:latest &&
$DOCKER_CMD pull quay.io/honestbuildings/hb_mock_api:2018-09-11

if [ $? -ne 0 ]; then
  echo -e "${RED}Loading docker images from quay.io failed:";
  echo -e "Please make sure you followed the above steps for logging in to quay.io AND running the docker login command."
  echo -e "The script will need to be re-run.  If it continues to fail please contact the HB DevOps Team"
  echo -e "${NC}";
  exit 1;
fi

if [ "$OS" == "MAC" ]; then
    # enable the nginx launchctl config
    echo "Enabling the nginx launchctl config";
    ln -sfv /usr/local/opt/nginx/*.plist ~/Library/LaunchAgents

    # Copy nginx vhost server block
    echo "Configuring nginx for local.honestbuildings.com"
    echo "$NGINX_SETTINGS" > /usr/local/etc/nginx/servers/default.conf

    # Starting Nginx
    echo "Starting Nginx"
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist
fi

# Build Java
cd "$DEV_DIR"/hbng/java || exit 1;

sudo docker-compose kill -s SIGINT

# Prompt if you want to completely clean your git directory
# This will remove all non tracked files
while true; do
    read -p "Do you want to git clean -fdx? This will remove all non tracked files ( IntelliJ Settings, composer files ) [y/N]" yn
    case $yn in
        [Yy]* ) git clean -fdx; break;;
        [Nn]* ) echo "You will need to rebuild php"; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Prompts user to remove danging/not needed images
$DOCKER_CMD system prune

$DOCKER_CMD build . #Otherwise I have seen distDocker step Hang

./gradlew clean build distDocker -x test -x spotbugsMain -x spotbugsTest -x pmdMain -x pmdTest -x checkstyleMain -x checkstyleTest;

sudo docker-compose up -d

cd "$DEV_DIR"/hbng/test || exit 1

rm -r node_modules || echo 'No node_modules to remove'

npm install

echo "Creating Integration Test secrets in /usr/local/.integration-secrets.json and will backup existing secrets to /usr/local/.integration-secrets.json.bk"

npm run init

COUNTER=0
# 3 minutes timeout for migrations
MAX_SLEEPS=36;
SLEEP_INTERVAL=5;
MINUTE_IN_SECONDS=60;

# Wait for php + java healthcheck to be up
until [[ "200" == $(curl -o /dev/null -s -w "%{http_code}" 0.0.0.0:8888/0.1/up) ]]; do
    ((COUNTER++))
    if [ $COUNTER -gt $MAX_SLEEPS ]; then
        echo "Backend services took more than" $((MAX_SLEEPS*SLEEP_INTERVAL/MINUTE_IN_SECONDS)) "minutes. Exiting."
        exit 1;
    fi
    echo "Searching for healthy backend services"
    sleep $SLEEP_INTERVAL
done

# Install composer
$DOCKER_CMD exec -it hbng_api_1 /bin/bash -c 'cd /opt/api/composer && ./composer.phar install'

# Update composer
$DOCKER_CMD exec -it hbng_api_1 /bin/bash -c 'cd /opt/api/composer && ./composer.phar update'

# Generate doctrine proxies
$DOCKER_CMD exec -it hbng_api_1 /bin/bash -c '(APP_SERVER_ENV=docker ./bin/orm-generate-proxies)'

cd "$DEV_DIR"/hbng/angularjs || exit 1;

rm -r node_modules || echo 'No node_modules to remove'

npm install

npm run webpack

if [ "$OS" == "MAC" ]; then
    brew services stop nginx
    brew services start nginx
fi

echo -e "\n\nInstall script completed! Go to http://local.honestbuildings.com:8080 to view the website!"

echo "Installing Xudo from local files"
cd "$DEV_DIR"/hbng/xudo || exit 1;
python3 setup.py install