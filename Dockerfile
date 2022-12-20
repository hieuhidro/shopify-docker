FROM ruby:slim-buster

ENV CLI_VERSION 2.33.0

ENV SHOPIFY_CLI_DEPS build-essential \
                    libffi-dev \
                    ruby-dev \
                    sudo

RUN apt update \
    && apt install $SHOPIFY_CLI_DEPS -y \
    && gem install shopify-cli -v $CLI_VERSION \
    && mkdir -p ~/.config/shopify \
    && printf "[analytics]\nenabled = false\n" > ~/.config/shopify/config \
    && curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - \
    && sudo apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /shopify

ENTRYPOINT [ "shopify" ]
CMD ["version"]