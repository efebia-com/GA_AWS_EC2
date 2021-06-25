apt -y update

curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -
apt -y install nodejs
apt -y install npm
npm install -g pm2
pm2 update
