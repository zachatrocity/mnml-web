# Download web libraries
libs:
    # Install Caddy server
    curl -sS https://webi.sh/caddy | sh
    # Create directory for libs
    mkdir -p app/libs
    curl -L "https://cdnjs.cloudflare.com/ajax/libs/milligram/1.4.1/milligram.min.css" -o app/libs/milligram.min.css
    # reset
    curl -L "https://cdnjs.cloudflare.com/ajax/libs/normalize/8.0.1/normalize.css" -o app/libs/normalize.css
    # fixi
    curl -L "https://raw.githubusercontent.com/bigskysoftware/fixi/refs/heads/master/fixi.js" -o app/libs/fixi.js
    # css-scope-inline
    curl -L "https://cdn.jsdelivr.net/gh/gnat/css-scope-inline@main/script.js" -o app/libs/css-scopes.js

# Start development server with live reload
dev:
    #!/usr/bin/env bash
    # Start both servers in parallel
    caddy run --config Caddyfile.dev --adapter caddyfile & \
    ./scripts/watch.sh

# Start production server
prod:
    caddy run --config Caddyfile --adapter caddyfile

# Deploy to cloudflare, fly, whatever
deploy:
    npx wrangler pages deploy ./app # cloudflare
    # flyctl launch # assumes fly.toml setup
    # npx gh-pages -d ./app # github pages
    # tar -C app -cvz . & hut pages publish -d username.srht.site site.tar.gz