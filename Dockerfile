#
# Dockerfile for scrapyd
#

FROM debian:bookworm
MAINTAINER EasyPi Software Foundation

ARG TARGETPLATFORM
ARG SCRAPY_VERSION=2.11.2
ARG SCRAPYD_VERSION=1.4.3
ARG SCRAPYD_CLIENT_VERSION=v1.2.3
ARG SCRAPY_SPLASH_VERSION=0.9.0
ARG SCRAPYRT_VERSION=v0.16.0
ARG SPIDERMON_VERSION=1.22.0
ARG SCRAPY_POET_VERSION=0.22.6
ARG SCRAPY_PLAYWRIGHT_VERSION=v0.0.38

SHELL ["/bin/bash", "-c"]

RUN set -xe \
    && echo ${TARGETPLATFORM} \
    && apt-get update \
    && apt-get install -y autoconf \
                          build-essential \
                          curl \
                          git \
                          libffi-dev \
                          libssl-dev \
                          libtool \
                          libxml2 \
                          libxml2-dev \
                          libxslt1.1 \
                          libxslt1-dev \
                          python3 \
                          python3-cryptography \
                          python3-dev \
                          python3-distutils \
                          python3-pil \
                          python3-pip \
                          tini \
                          vim-tiny \
    && if [[ ${TARGETPLATFORM} = "linux/arm/v7" ]]; then apt install -y cargo; fi \
    && rm -f /usr/lib/python3.11/EXTERNALLY-MANAGED \
    && pip install --no-cache-dir boto3 dateparser ipython \
                   https://github.com/scrapy/scrapy/archive/refs/tags/$SCRAPY_VERSION.zip \
                   https://github.com/scrapy/scrapyd/archive/refs/tags/$SCRAPYD_VERSION.zip \
                   https://github.com/scrapy/scrapyd-client/archive/refs/tags/$SCRAPYD_CLIENT_VERSION.zip \
                   https://github.com/scrapy-plugins/scrapy-splash/archive/refs/tags/$SCRAPY_SPLASH_VERSION.zip \
                   https://github.com/scrapinghub/scrapyrt/archive/refs/tags/$SCRAPYRT_VERSION.zip \
                   https://github.com/scrapinghub/spidermon/archive/refs/tags/$SPIDERMON_VERSION.zip \
                   https://github.com/scrapinghub/scrapy-poet/archive/refs/tags/$SCRAPY_POET_VERSION.zip \
                   https://github.com/scrapy-plugins/scrapy-playwright/archive/refs/tags/$SCRAPY_PLAYWRIGHT_VERSION.zip \
    && mkdir -p /etc/bash_completion.d \
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
    && rm -rf /var/lib/apt/lists/*

COPY ./scrapyd.conf /etc/scrapyd/
VOLUME /etc/scrapyd/ /var/lib/scrapyd/
EXPOSE 6800

ENTRYPOINT ["tini", "--"]
CMD ["scrapyd", "--pidfile="]
