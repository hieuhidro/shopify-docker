FROM debian:buster-slim as ruby-build

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		bzip2 \
		ca-certificates \
		libffi-dev \
		libgmp-dev \
		libssl-dev \
		libyaml-dev \
		procps \
		zlib1g-dev \
	; \
	rm -rf /var/lib/apt/lists/*

# skip installing gem documentation
RUN set -eux; \
	mkdir -p /usr/local/etc; \
	{ \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /usr/local/etc/gemrc

ENV LANG C.UTF-8
ENV RUBY_MAJOR 3.0
ENV RUBY_VERSION 3.0.5
ENV RUBY_DOWNLOAD_SHA256 cf7cb5ba2030fe36596a40980cdecfd79a0337d35860876dc2b10a38675bddde

# some of ruby's build scripts are written in ruby
#   we purge system ruby later to make sure our final image uses what we just built
RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		bison \
		dpkg-dev \
		libgdbm-dev \
		ruby \
		autoconf \
		g++ \
		gcc \
		libbz2-dev \
		libgdbm-compat-dev \
		libglib2.0-dev \
		libncurses-dev \
		libreadline-dev \
		libxml2-dev \
		libxslt-dev \
		make \
		wget \
		xz-utils \
	; \
	rm -rf /var/lib/apt/lists/*; \
    \
    wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz"; \
	echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum --check --strict; \
	\
	mkdir -p /usr/src/ruby; \
	tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1; \
	rm ruby.tar.xz; \
	\
	cd /usr/src/ruby; \
	\
# hack in "ENABLE_PATH_CHECK" disabling to suppress:
#   warning: Insecure world writable dir
	{ \
		echo '#define ENABLE_PATH_CHECK 0'; \
		echo; \
		cat file.c; \
	} > file.c.new; \
	mv file.c.new file.c; \
	\
	autoconf; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	./configure \
		--build="$gnuArch" \
		--disable-install-doc \
		--enable-shared \
	; \
	make -j "$(nproc)"; \
    cd / \
    && tar -zcvf /rubypackage.tar.gz /usr/src/ruby; \
    rm -rf usr/src/ruby; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark > /dev/null; \
    find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
        | awk '/=>/ { print $(NF-1) }' \
        | sort -u \
        | grep -vE '^/usr/local/lib/' \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual \
    ;

FROM ruby:3.0.5-slim as ruby3-0-build

FROM node:lts-slim

COPY --from=ruby-build /rubypackage.tar.gz /rubypackage.tar.gz
# skip installing gem documentation
RUN set -eux; \
	mkdir -p /usr/local/etc; \
	{ \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /usr/local/etc/gemrc


# (see persistent deps below)
ENV SHOPIFY_DEPS \
		curl \
		g++ \
		gcc \
		make \
		libbz2-dev \
		libgdbm-compat-dev \
		libglib2.0-dev \
		libncurses-dev \
		libreadline-dev \
		libxml2-dev \
		libxslt-dev \
		ruby-dev \
		ruby-full

# persistent / runtime deps
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		$SHOPIFY_DEPS \
	; \
    mkdir -p ~/.config/shopify \
    && printf "[analytics]\nenabled = false\n" > ~/.config/shopify/config ; \
	rm -rf /var/lib/apt/lists/*;

RUN set -eux; \
    cd /; \
    mkdir -p /usr/src/ruby; \
    tar xvfz /rubypackage.tar.gz usr/src/ruby -C /usr/src/ruby; \
    rm  /rubypackage.tar.gz; \
    ls -al /usr/src/ruby; \
    cd /usr/src/ruby; \
    make install; \
#    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    gem install bundler; \
    cd /; \
    rm -rf /usr/src/ruby; \
	rm -rf /var/lib/apt/lists/*

## INSTALL RUBY
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$PATH
# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"

COPY --from=ruby3-0-build /usr/local/lib/ruby/3.0.0 /usr/local/lib/ruby/3.0.0

RUN set -eux; \
    npm install -g @shopify/cli @shopify/app @shopify/theme @shopify/ngrok \
    && npm cache clean --force && rm -rf /tmp/* ;

# Remove fix authrorize.js
#RUN cd /usr/local/lib/node_modules/\@shopify && \
#    grep -IRl "127.0.0.1" ./ | grep 'authorize.js' | xargs sed -i 's/127.0.0.1/0.0.0.0/g' && \
#    grep -IRl 'http://${host}' ./ | grep 'authorize.js' | xargs sed -i 's/http:\/\/\${host}/http:\/\/127.0.0.1/g'

# Configure Node.js version
#RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash

# Install shopify
#RUN npm install -g @shopify/cli @shopify/theme

# Install themekit
# RUN curl -s https://shopify.dev/themekit.py | sudo python3

WORKDIR /shopify

#ENV PORTS 3000
#
#EXPOSE 3456 8081 $PORTS 8082
COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]

CMD ["shopify"]
