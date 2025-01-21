deps:
    curl -sS https://webi.sh/caddy | sh
    # Install tools for development live reload
    sudo apt-get update && sudo apt-get install -y inotify-tools
    # Download pre-built websocat binary
    go get github.com/jhkennedy4/caddy-hot-watcher

# Download external libraries
libs:
    mkdir -p libs
    curl -L "https://cdnjs.cloudflare.com/ajax/libs/milligram/1.4.1/milligram.min.css" -o app/libs/milligram.min.css
    # reset
    curl -L "https://cdnjs.cloudflare.com/ajax/libs/normalize/8.0.1/normalize.css" -o app/libs/normalize.css
    # fixi
    curl -L "https://raw.githubusercontent.com/bigskysoftware/fixi/refs/heads/master/fixi.js" -o app/libs/fixi.js
    # css-scope-inline
    curl -L "https://cdn.jsdelivr.net/gh/gnat/css-scope-inline@main/script.js" -o app/libs/css-scopes.js

# Start development server with live reload
dev:
    caddy run --config Caddyfile.dev --adapter caddyfile

# Start production server
prod:
    caddy run --config Caddyfile --adapter caddyfile
