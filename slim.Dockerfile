FROM ruby:slim-buster

# (see persistent deps below)
ENV SHOPIFY_DEPS \
		curl \
		g++ \
		make \
		gcc

# persistent / runtime deps
RUN set -eux \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		$SHOPIFY_DEPS \
    && gem install bundler \
	&& curl -sL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
	&& rm -rf /var/lib/apt/lists/*

ENV SHOPIFY_EXTENSION \
        @shopify/ngrok

RUN set -eux; \
    npm install -g @shopify/cli @shopify/app @shopify/theme $SHOPIFY_EXTENSION \
    && npm cache clean --force && rm -rf /tmp/*\
    && cd /usr/lib/node_modules/\@shopify \
    && grep -IRl "127.0.0.1" ./ | grep 'authorize.js' | xargs sed -i 's/127.0.0.1/0.0.0.0/g' \
    && grep -IRl 'http://${host}' ./ | grep 'authorize.js' | xargs sed -i 's/http:\/\/\${host}/http:\/\/127.0.0.1/g'

WORKDIR /shopify

#ENV PORTS 3000
#
#EXPOSE 3456 8081 $PORTS 8082
COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]

CMD ["shopify"]