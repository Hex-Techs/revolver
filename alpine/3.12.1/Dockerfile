FROM alpine:3.12.1

ENV LANG C.UTF-8

# If debug the container, you will run init command to set package manager mirror.
COPY init.sh /usr/sbin/init

RUN echo "#!/bin/bash" >> /usr/sbin/install \
    && echo "apk update" >> /usr/sbin/install \
    && echo "apk add --no-cache git openssh-client make vim tcpdump busybox-extras" >> /usr/sbin/install

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk update \
    && apk add --no-cache bash curl jq tini \
    && chmod +x /usr/sbin/init /usr/sbin/install

ENTRYPOINT ["tini", "--"]
