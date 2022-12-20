FROM node:buster-slim

# (see persistent deps below)
ENV SHOPIFY_DEPS \
        sudo \
		curl \
		g++ \
		gcc \
		python3 \
		ruby-full \
		ruby-dev

# persistent / runtime deps
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		$SHOPIFY_DEPS \
	; \
	rm -rf /var/lib/apt/lists/*

# Configure Node.js version
#RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash

# Install shopify
RUN npm install -g @shopify/cli @shopify/theme

# Install themekit
RUN curl -s https://shopify.dev/themekit.py | sudo python3

WORKDIR /shopify

ENV PORTS 3000

EXPOSE 3456 8081 $PORTS 8082

ENTRYPOINT ["/bin/bash"]

#CMD [ "bash" ]