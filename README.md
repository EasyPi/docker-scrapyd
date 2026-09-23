scrapyd
=======

[![](https://img.shields.io/github/actions/workflow/status/easypi/docker-scrapyd/build.yaml?logo=github&style=flat-square)](https://github.com/EasyPi/docker-scrapyd)
[![](https://img.shields.io/docker/stars/easypi/scrapyd?logo=docker&style=flat-square)](https://hub.docker.com/r/easypi/scrapyd)
[![](https://img.shields.io/github/license/easypi/docker-scrapyd?style=flat-square)](LICENSE.md)

![](https://img.shields.io/badge/linux-amd64-orange.svg?logo=linux&style=flat-square)
![](https://img.shields.io/badge/linux-arm64-orange.svg?logo=linux&style=flat-square)
![](https://img.shields.io/badge/debian-trixie-A81D33.svg?logo=debian&style=flat-square)
![](https://img.shields.io/badge/python-3.13-blue.svg?logo=python&style=flat-square)

[scrapy][1] is an open source and collaborative framework for extracting the
data you need from websites. In a fast, simple, yet extensible way.

[scrapyd][2] is a service for running Scrapy spiders.  It allows you to deploy
your Scrapy projects and control their spiders using a HTTP JSON API.

[scrapyd-client][3] is a client for scrapyd. It provides the scrapyd-deploy
utility which allows you to deploy your project to a Scrapyd server.

[scrapy-splash][4] provides Scrapy+JavaScript integration using Splash.

[scrapyrt][5] allows you to easily add HTTP API to your existing Scrapy project.

[spidermon][6] is a framework to build monitors for Scrapy spiders.

[scrapy-poet][7] is the web-poet Page Object pattern implementation for Scrapy.

[scrapy-playwright][8] is a Scrapy Download Handler which performs requests using Playwright for Python.

This image is based on `debian:trixie`, 8 latest stable python packages are installed:

<details>
<summary>pip-outdated</summary>

```bash
$ pipx install pip-outdated
$ pip-outdated requirements.txt
```

| Name              | Installed | Wanted | Latest |
|-------------------|-----------|--------|--------|
| scrapy            | None      | 2.19.0 | 2.19.0 |
| scrapyd           | None      | 1.6.0  | 1.6.0  |
| scrapyd-client    | None      | 2.0.3  | 2.0.3  |
| scrapy-splash     | None      | 0.11.1 | 0.11.1 |
| scrapyrt          | None      | 0.18.1 | 0.18.1 |
| spidermon         | None      | 1.27.0 | 1.27.0 |
| scrapy-poet       | None      | 0.27.2 | 0.27.2 |
| scrapy-playwright | None      | 0.0.48 | 0.0.48 |

</details>

> [!Tip]
> Please use this as base image for your own project.

> [!Caution]
> Scrapy (since [2.0.0][9]) has dropped support for Python 2.7, which reached end-of-life on 2020-01-01.

## docker-compose.yml

```yaml
services:

  scrapyd:
    image: easypi/scrapyd
    ports:
      - "6800:6800"
    volumes:
      - ./data:/var/lib/scrapyd
      - /usr/local/lib/python3.11/dist-packages
    restart: unless-stopped

  scrapy:
    image: easypi/scrapyd
    command: bash
    volumes:
      - .:/code
    working_dir: /code
    restart: unless-stopped

  scrapyrt:
    image: easypi/scrapyd
    command: scrapyrt -i 0.0.0.0 -p 9080
    ports:
      - "9080:9080"
    volumes:
      - .:/code
    working_dir: /code
    restart: unless-stopped
```

## Run it as background-daemon for scrapyd

```bash
$ docker-compose up -d scrapyd
$ docker-compose logs -f scrapyd
$ docker cp scrapyd_scrapyd_1:/var/lib/scrapyd/items .
$ tree items
└── myproject
    └── myspider
        └── ad6153ee5b0711e68bc70242ac110005.jl
```

```bash
$ mkvirtualenv -p python3 webbot
$ pip install scrapy scrapyd-client

$ scrapy startproject myproject
$ cd myproject
$ setvirtualenvproject

$ scrapy genspider myspider mydomain.com
$ scrapy edit myspider
$ scrapy list

$ vi scrapy.cfg
$ scrapyd-client deploy
$ curl http://localhost:6800/schedule.json -d project=myproject -d spider=myspider
$ curl http://localhost:6800/daemonstatus.json
$ firefox http://localhost:6800
```

File: scrapy.cfg

```ini
[settings]
default = myproject.settings

[deploy]
url = http://localhost:6800/
project = myproject
```

## Run it as interactive-shell for scrapy

```bash
$ cat > stackoverflow_spider.py << _EOF_
import scrapy

class StackOverflowSpider(scrapy.Spider):
    name = 'stackoverflow'
    start_urls = ['http://stackoverflow.com/questions?sort=votes']

    def parse(self, response):
        for href in response.css('.question-summary h3 a::attr(href)'):
            full_url = response.urljoin(href.extract())
            yield scrapy.Request(full_url, callback=self.parse_question)

    def parse_question(self, response):
        yield {
            'title': response.css('h1 a::text').extract()[0],
            'votes': response.css('.question div[itemprop="upvoteCount"]::text').extract()[0],
            'body': response.css('.question .postcell').extract()[0],
            'tags': response.css('.question .post-tag::text').extract(),
            'link': response.url,
        }
_EOF_

$ docker-compose run --rm scrapy
>>> scrapy runspider stackoverflow_spider.py -o top-stackoverflow-questions.jl
>>> cat top-stackoverflow-questions.jl
>>> exit
```

## Run it as realtime crawler for scrapyrt

```bash
$ git clone https://github.com/scrapy/quotesbot.git .
$ docker-compose up -d scrapyrt
$ curl -s 'http://localhost:9080/crawl.json?spider_name=toscrape-css&callback=parse&url=http://quotes.toscrape.com/&max_requests=5' | jq -c '.items[]'
```

[1]: https://github.com/scrapy/scrapy
[2]: https://github.com/scrapy/scrapyd
[3]: https://github.com/scrapy/scrapyd-client
[4]: https://github.com/scrapinghub/scrapy-splash
[5]: https://github.com/scrapinghub/scrapyrt
[6]: https://github.com/scrapinghub/spidermon
[7]: https://github.com/scrapinghub/scrapy-poet
[8]: https://github.com/scrapy-plugins/scrapy-playwright
[9]: <https://docs.scrapy.org/en/latest/news.html#scrapy-2-0-0-2020-03-03>
