#!/bin/sh

echo "setup MySQL Database user info..."
${ROOT_DIR}/bin/config set mysql.host ${MYSQL_HOST}
${ROOT_DIR}/bin/config set mysql.user ${MYSQL_USER}
${ROOT_DIR}/bin/config set mysql.pass ${MYSQL_PASS}
${ROOT_DIR}/bin/storage upgrade --force
echo "

"

echo "setup smtp info..."
${ROOT_DIR}/bin/config set metamta.default-address ${SMTP_USER}
# ${ROOT_DIR}/bin/config set metamta.domain ${SERVER_NAME}
${ROOT_DIR}/bin/config set metamta.can-send-as-user false
# ${ROOT_DIR}/bin/config set metamta.mail-adapter PhabricatorMailImplementationPHPMailerAdapter
# ${ROOT_DIR}/bin/config set phpmailer.mailer smtp
# ${ROOT_DIR}/bin/config set phpmailer.smtp-host ${SMTP_HOST}
# ${ROOT_DIR}/bin/config set phpmailer.smtp-port ${SMTP_PORT}
# ${ROOT_DIR}/bin/config set phpmailer.smtp-user ${SMTP_USER}
# ${ROOT_DIR}/bin/config set phpmailer.smtp-password ${SMTP_PASS}
# ${ROOT_DIR}/bin/config set phpmailer.smtp-protocol SSL
${ROOT_DIR}/bin/config set --stdin cluster.mailers < /cluster-mailer.json
echo "

"

echo "setup nginx config file..."
sed -i "s/SERVER_NAME/${SERVER_NAME}/" /etc/nginx/nginx.conf
echo "

"

chown -R git.git /var/data /var/repo

${ROOT_DIR}/bin/config set environment.append-paths '["/usr/libexec/git-core", "/bin", "/usr/bin", "/usr/local/bin"]'
${ROOT_DIR}/bin/config set phabricator.base-uri https://${SERVER_NAME}
${ROOT_DIR}/bin/config set storage.local-disk.path /var/data
${ROOT_DIR}/bin/config set phd.user root
${ROOT_DIR}/bin/config set diffusion.ssh-user git
${ROOT_DIR}/bin/config set security.require-https 'true'

echo "start phabricator..."
${ROOT_DIR}/bin/phd start
/usr/sbin/sshd -f /etc/ssh/sshd_config.phabricator
php-fpm

phd_pid=`ps -ef | grep phd | grep -v grep | awk -F ' ' '{print $2}'`
sshd_pid=`ps -ef | grep sshd | grep -v grep | awk -F ' ' '{print $2}'`
fpm_pid=`ps -ef | grep fpm | grep -v grep | awk -F ' ' '{print $2}'`

if [ "${phd_pid}" != "" ]; then
    echo "phd is already running, pid is ${phd_pid}"
else
    echo "phd not runnig..."
    exit 1
fi

if [ "${sshd_pid}" != "" ]; then
    echo "sshd is already running..."
else
    echo "sshd not running..."
    exit 1
fi

if [ "${fpm_pid}" != "" ]; then
    echo "fpm is already running..."
else
    echo "fpm not running..."
    exit 1
fi

nginx

while :
do
    sleep 3600
done
