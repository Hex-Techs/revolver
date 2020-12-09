#!/bin/sh

echo "will setup pahbricator..."
sed -i "/case PhabricatorDatabaseRef::REPLICATION_MASTER_REPLICA:/ a\break;" /usr/share/nginx/phabricator/src/applications/config/check/PhabricatorDatabaseSetupCheck.php
echo "

"

echo "setup git ssh..."
cp ${ROOT_DIR}/resources/sshd/phabricator-ssh-hook.sh /usr/libexec/phabricator-ssh-hook.sh
cp ${ROOT_DIR}/resources/sshd/sshd_config.phabricator.example /etc/ssh/sshd_config.phabricator
sed -i 's/vcs-user/git/' /usr/libexec/phabricator-ssh-hook.sh
sed -i "s#/path/to/phabricator#${ROOT_DIR}#" /usr/libexec/phabricator-ssh-hook.sh
sed -i 's/Port 2222/Port 22/' /etc/ssh/sshd_config.phabricator
# sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.phabricator
sed -i 's/AuthorizedKeysCommandUser vcs-user/AuthorizedKeysCommandUser git/' /etc/ssh/sshd_config.phabricator
sed -i 's/AllowUsers vcs-user/AllowUsers git/' /etc/ssh/sshd_config.phabricator
echo " " >> /etc/ssh/sshd_config.phabricator
echo "HostKey /etc/ssh/key/ssh_host_rsa_key" >> /etc/ssh/sshd_config.phabricator
echo "HostKey /etc/ssh/key/ssh_host_dsa_key" >> /etc/ssh/sshd_config.phabricator
echo "HostKey /etc/ssh/key/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config.phabricator
echo "HostKey /etc/ssh/key/ssh_host_ed25519_key" >> /etc/ssh/sshd_config.phabricator
