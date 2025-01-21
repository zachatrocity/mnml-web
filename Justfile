deps:
    curl -sS https://webi.sh/caddy | sh
    # Install tools for development live reload
    sudo apt-get update && sudo apt-get install -y inotify-tools
    # Download pre-built websocat binary
    curl -L https://github.com/vi/websocat/releases/download/v1.11.0/websocat.x86_64-unknown-linux-musl -o websocat
    chmod +x websocat
    sudo mv websocat /usr/local/bin/

# Download external libraries
libs:
    mkdir -p libs
    curl -L "https://cdnjs.cloudflare.com/ajax/libs/milligram/1.4.1/milligram.min.css" -o libs/milligram.min.css
    # reset
    curl -L "https://cdnjs.cloudflare.com/ajax/libs/normalize/8.0.1/normalize.css" -o libs/normalize.css
    # fixi
    curl -L "https://raw.githubusercontent.com/bigskysoftware/fixi/refs/heads/master/fixi.js" -o libs/fixi.js
    # css-scope-inline
    curl -L "https://cdn.jsdelivr.net/gh/gnat/css-scope-inline@main/script.js" -o libs/css-scopes.js

# Start development server with live reload
dev:
    ./watch.sh & caddy run --config Caddyfile.dev

# Start production server
prod:
    caddy run --config Caddyfile
