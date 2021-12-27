#
# Dockerfile for scrapyd
#

FROM debian:bullseye
MAINTAINER EasyPi Software Foundation

ARG TARGETPLATFORM

ENV SCRAPY_VERSION=2.5.1
ENV SCRAPYD_VERSION=1.2.1
ENV SCRAPYD_CLIENT_VERSION=v1.2.0
ENV SCRAPYRT_VERSION=v0.13
ENV SPIDERMON_VERSION=1.16.2
ENV PILLOW_VERSION=8.4.0

SHELL ["/bin/bash", "-c"]

RUN set -xe \
    && echo ${TARGETPLATFORM} \
    && apt-get update \
    && apt-get install -y autoconf \
                          build-essential \
                          curl \
                          libffi-dev \
                          libssl-dev \
                          libtool \
                          libxml2 \
                          libxml2-dev \
                          libxslt1.1 \
                          libxslt1-dev \
                          python3 \
                          python3-dev \
                          python3-distutils \
                          tini \
                          vim-tiny \
    && apt-get install -y libtiff5 \
                          libtiff5-dev \
                          libfreetype6-dev \
                          libjpeg62-turbo \
                          libjpeg62-turbo-dev \
                          liblcms2-2 \
                          liblcms2-dev \
                          libwebp6 \
                          libwebp-dev \
                          zlib1g \
                          zlib1g-dev \
    && if [[ ${TARGETPLATFORM} = "linux/arm/v7" ]]; then apt install -y cargo; fi \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | python3 \
    && pip install --no-cache-dir ipython \
                   https://github.com/scrapy/scrapy/archive/refs/tags/$SCRAPY_VERSION.zip \
                   https://github.com/scrapy/scrapyd/archive/refs/tags/$SCRAPYD_VERSION.zip \
                   https://github.com/scrapy/scrapyd-client/archive/refs/tags/$SCRAPYD_CLIENT_VERSION.zip \
                   https://github.com/scrapy-plugins/scrapy-splash/archive/refs/heads/master.zip \
                   https://github.com/scrapinghub/scrapyrt/archive/refs/tags/$SCRAPYRT_VERSION.zip \
                   https://github.com/scrapinghub/spidermon/archive/refs/tags/$SPIDERMON_VERSION.zip \
                   https://github.com/python-pillow/Pillow/archive/refs/tags/$PILLOW_VERSION.zip \
    && curl -sSL https://github.com/scrapy/scrapy/raw/master/extras/scrapy_bash_completion -o /etc/bash_completion.d/scrapy_bash_completion \
    && echo 'source /etc/bash_completion.d/scrapy_bash_completion' >> /root/.bashrc \
    && if [[ ${TARGETPLATFORM} = "linux/arm/v7" ]]; then apt purge -y --auto-remove cargo; fi \
    && apt-get purge -y --auto-remove autoconf \
                                      build-essential \
                                      curl \
                                      libffi-dev \
                                      libssl-dev \
                                      libtool \
                                      libxml2-dev \
                                      libxslt1-dev \
                                      python3-dev \
    && apt-get purge -y --auto-remove libtiff5-dev \
                                      libfreetype6-dev \
                                      libjpeg62-turbo-dev \
                                      liblcms2-dev \
                                      libwebp-dev \
                                      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY ./scrapyd.conf /etc/scrapyd/
VOLUME /etc/scrapyd/ /var/lib/scrapyd/
EXPOSE 6800

ENTRYPOINT ["tini", "--"]
CMD ["scrapyd", "--pidfile="]
