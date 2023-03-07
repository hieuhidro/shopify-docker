# Shopify-CLI Tool package

Shopify CLI is a command-line interface tool that helps you build Shopify apps and themes. It quickly generates Node.js, Ruby on Rails, and PHP apps, app extensions, and Shopify themes. You can also use it to automate many common development tasks.

Theme Kit is a cross-platform command line tool that you can use to build Shopify themes.

## How to use this image

### DOCKER
```
docker run --rm -p 3456:3456 -v local_folder:/shopify hieuhidro/shopify:cli-2.33 login
``` 

### DOCKER COMPOSE

- **docker-compose.yml:**
```
services:
  shopify:
    image: hieuhidro/shopify:cli-2.33
    volumes:
      - ./theme-custom-dawn:/shopify
      - ./config:/root/.config/shopify/config
      - ./.cache:/root/.cache
    environment: 
# For shopify v3 only
      - SHOPIFY_CLI_NO_ANALYTICS=[1|0]
      - SHOPIFY_CLI_THEME_TOKEN=[Your theme password (https://apps.shopify.com/theme-access)]
      - SHOPIFY_CLI_TTY=0
      - SHOPIFY_CLI_DEVICE_AUTH=[1|0]
      - SHOPIFY_FLAG_STORE=[Your Store URL]
# For nginx-proxy 
      - VIRTUAL_HOST=local-domain
      - VIRTUAL_PORT=9292
      - SERVER_HOST_IP=[Host IP:172.17.0.1]
      - CERT_NAME=default
      - HTTPS_METHOD=[noredirect|redirect]
# For nginx-proxy 
    ports:
      - '3456:3456'
      - '9292:9292'
      - '8081:8081'
  theme:
    image: hieuhidro/shopify:themekit-1.3.1
    volumes:
      - ./theme-custom-dawn:/shopify
      - ./config:/root/.config/shopify/config
      - ./.cache:/root/.cache
    environment:
      - THEMEKIT_PASSWORD=[Your theme password (https://apps.shopify.com/theme-access)]
      - THEMEKIT_THEME_ID=[Your theme ID]
      - THEMEKIT_STORE=[Your Store URL]
      - SHOPIFY_CLI_DEVICE_AUTH=[1|0]
      - 'THEMEKIT_IGNORE_FILES=*.gif:*.jpg:config/settings_data.json'
    ports:
      - '3456:3456'
      - '9292:9292'
      - '8081:8081'
# For nginx-proxy 
    networks:
      - default
      - proxy

networks:
  proxy:
    external: true
# For nginx-proxy 
```

- **docker-compose**
```
docker-compose run --rm --service-ports [shopify/theme] help
```

- **Starting development a theme**
```
docker-compose run --rm --service-ports shopify theme dev
```

### Access to the container
```
docker run --rm -it hieuhidro/shopify:cli-3.30 bash
```
or
```
docker-compose run --rm --service-ports shopify bash
```

## Adding more npm shopify extensions: using env

```
NPM_EXTENSION=@shopify/ngrok
```

## NGINX-PROXY (Check the docker-compose.yml)

Running the shopify theme development under nginx-proxy

- Proxy docker image: https://hub.docker.com/r/jwilder/nginx-proxy
- VIRTUAL_HOST=local-domain
- VIRTUAL_PORT=9292
- SERVER_HOST_IP=[Host IP:172.17.0.1]
- CERT_NAME=default
- HTTPS_METHOD=noredirect
- ...

## themekit:

- Docker tag: **themekit**.
- Themkit cli image referrer here https://shopify.dev/themes/tools/theme-kit

## shopify-cli v2:
- Docker tag: **cli-2.xx**.
- shopify-cli v2 image https://shopify.dev/themes/tools/cli/cli-2

## shopify-cli v3
- Docker tag: **cli-3.xx**.
- shopify-cli v3 image https://shopify.dev/themes/tools/cli

# Specifications

- Got issue while logging? Try this out [[Github Link](https://github.com/Shopify/cli/pull/964#issuecomment-1398232063)]


