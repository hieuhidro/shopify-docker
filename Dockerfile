FROM ruby:slim

# (see persistent deps below)
ENV SHOPIFY_DEPS \
        sudo \
		curl \
		g++ \
		gcc \
		python

RUN apt update \
    && apt install -y --no-install-recommends \
    $SHOPIFY_DEPS \
    && mkdir -p ~/.config/shopify \
    && printf "[analytics]\nenabled = false\n" > ~/.config/shopify/config \
    # Configure Node.js version
    && curl -sL https://deb.nodesource.com/setup_lts.x | bash \
    && rm -rf /var/lib/apt/lists/*

RUN curl -s https://shopify.dev/themekit.py | sudo python3

WORKDIR /shopify

ENTRYPOINT [ "theme" ]
CMD ["version"]