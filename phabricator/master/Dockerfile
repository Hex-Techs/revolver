# TAGS=200810
FROM centos:7.6.1810

RUN useradd git && usermod -p NP git &&  yum update -y && yum install -y epel-release openssh-server \
    && yum install -y git nginx

RUN git clone https://github.com/phacility/libphutil.git "/usr/share/nginx/libphutil"
RUN git clone https://github.com/phacility/arcanist.git "/usr/share/nginx/arcanist"
RUN git clone https://github.com/phacility/phabricator.git "/usr/share/nginx/phabricator"

# install requirment package
RUN yum install -y https://mirror.webtatic.com/yum/el7/webtatic-release.rpm \
    && yum install -y php71w-devel php71w php71w-cli php71w-common php71w-gd \
    php71w-ldap php71w-mbstring php71w-mysqlnd  php71w-fpm php71w-process php71w-opcache \
    yum install nodejs python-pygments which sudo -y && yum clean all

COPY nginx.conf /etc/nginx/nginx.conf
COPY install.sh /install.sh
COPY cluster-mailer.json /cluster-mailer.json
COPY run.sh /run.sh
COPY preamble.php /usr/share/nginx/phabricator/support/preamble.php

# set env
ENV SERVER_NAME="" \
    MYSQL_HOST="" \
    MYSQL_USER="root" \
    MYSQL_PASS="" \
    SMTP_HOST="" \
    SMTP_PASS="" \
    SMTP_PORT=465 \
    SMTP_PROTOCOL="ssl" \
    SMTP_USER="" \
    ROOT_DIR="/usr/share/nginx/phabricator"

RUN chmod +x /install.sh && chmod +x /run.sh && /bin/sh -c /install.sh && \
    sed -i "s/post_max_size = 8M/post_max_size = 2048M/" /etc/php.ini && \
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 30M/" /etc/php.ini && \
    echo " " >> /etc/php.ini && echo "date.timezone = Asia/Shanghai" >> /etc/php.ini && \
    echo "opcache.validate_timestamps = 0" >> /etc/php.ini && echo " " >> /etc/sudoers && \
    echo "git  ALL=(ALL) SETENV: NOPASSWD: /bin/ls, /usr/bin/git, /usr/bin/git-upload-pack, /usr/bin/git-receive-pack, /usr/bin/ssh" >> /etc/sudoers && \
    mkdir /var/data /var/repo

EXPOSE 22 80

VOLUME [ "/var/data", "/var/repo" ]

ENTRYPOINT [ "/run.sh" ]
