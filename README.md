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
      - SHOPIFY_CLI_THEME_TOKEN=[Your theme password]
      - SHOPIFY_CLI_TTY=0
      - SHOPIFY_CLI_DEVICE_AUTH=[1|0]
      - SHOPIFY_FLAG_STORE=[Your Store URL]
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
      - THEMEKIT_PASSWORD=[Your theme password]
      - THEMEKIT_THEME_ID=[Your theme ID]
      - THEMEKIT_STORE=[Your Store URL]
      - SHOPIFY_CLI_DEVICE_AUTH=[1|0]
      - 'THEMEKIT_IGNORE_FILES=*.gif:*.jpg:config/settings_data.json'
    ports:
      - '3456:3456'
      - '9292:9292'
      - '8081:8081'
```

- **docker-compose**
```
docker-compose run --rm --service-ports [shopify/theme] help
```
### Access to the container

```
docker run --rm -it hieuhidro/shopify:cli-3.30 bash
```

## Adding more npm shopify extensions: using env

```
SHOPIFY_EXTENSION=@shopify/ngrok
```

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


