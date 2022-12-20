FROM node:buster-slim

# (see persistent deps below)
ENV SHOPIFY_DEPS \
		curl \
		g++ \
		gcc \
		ruby-full \
		ruby-dev

# persistent / runtime deps
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		$SHOPIFY_DEPS \
	; \
    mkdir -p ~/.config/shopify \
    && printf "[analytics]\nenabled = false\n" > ~/.config/shopify/config ; \
	rm -rf /var/lib/apt/lists/*

# Configure Node.js version
#RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash

# Install shopify
RUN npm install -g @shopify/cli

# Install themekit
# RUN curl -s https://shopify.dev/themekit.py | sudo python3

#WORKDIR /shopify

#ENV PORTS 3000
#
#EXPOSE 3456 8081 $PORTS 8082

ENTRYPOINT [ "shopify" ]

CMD ["version"]