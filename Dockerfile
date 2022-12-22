FROM ruby:slim

# (see persistent deps below)
ENV SHOPIFY_DEPS \
        sudo \
		curl \
		g++ \
		gcc \
		python3

RUN set -eux; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
    $SHOPIFY_DEPS \
    && mkdir -p ~/.config/shopify \
    && printf "[analytics]\nenabled = false\n" > ~/.config/shopify/config \
    # Configure Node.js version
    curl -sL https://deb.nodesource.com/setup_lts.x | bash; \
    apt-get install -y --no-install-recommends nodejs \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN curl -s https://shopify.dev/themekit.py | sudo python3

WORKDIR /shopify
COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]

CMD ["theme"]