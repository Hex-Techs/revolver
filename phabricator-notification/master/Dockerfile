# TAGS=190823
FROM php:7.3.0-cli-alpine3.8

RUN apk add --update nodejs nodejs-npm git which && chmod 777 /var/log && \
    addgroup -S phabricator && adduser -S phabricator -G phabricator && \
    docker-php-ext-install pcntl && docker-php-ext-enable pcntl

RUN mkdir /data && git clone https://github.com/phacility/libphutil.git "/data/libphutil" && \
    git clone https://github.com/phacility/arcanist.git "/data/arcanist"
RUN git clone https://github.com/phacility/phabricator.git "/data/phabricator"

WORKDIR /data/phabricator/support/aphlict/server
RUN npm --registry=https://registry.npm.taobao.org --cache=$HOME/.npm/.cache/cnpm --disturl=https://npm.taobao.org/dist --userconfig=$HOME/.cnpmrc install ws && \
    chown -R phabricator.phabricator /data && \
    sed -i 's#/var/tmp/aphlict/pid/aphlict.pid#/tmp/aphlict.pid#' /data/phabricator/conf/aphlict/aphlict.default.json && \
    sed -i 's/127.0.0.1/0.0.0.0/' /data/phabricator/conf/aphlict/aphlict.default.json

WORKDIR /data/phabricator

EXPOSE 22280 22281

USER phabricator

CMD [ "/data/phabricator/bin/aphlict", "debug" ]
