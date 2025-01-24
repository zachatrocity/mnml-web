# mnml-web

Minimal web boilerplate without the existential depression.

`just libs` then `just dev`, man.

This is a bare-bones web setup strives to minimal. 

Just:
- Plain HTML/CSS/JS 
- A few simple tools that help your dev ex not suck 🤌
    - [fixi.js](https://github.com/bigskysoftware/fixi)
    - [css-scope-inline](https://github.com/gnat/css-scope-inline)
- Some optional CSS friends ([normalize.css](https://necolas.github.io/normalize.css/), [milligram](https://milligram.io)) for that 💅
- Zero-config live reload (see below)

Perfect for:
- Quick prototypes
- Learning web basics
- Remembering why we loved web dev before it got complicated
- Making something without installing half the internet

## SSLR - Stupid Simple Live Reload ✨

Because manually refreshing is for chumps

### How it Works

1. `watch.sh` stalks your `./app` directory using [fswatch](https://emcrisostomo.github.io/fswatch/)
2. [netcat](https://nc110.sourceforge.io/) sends a SSE to the browser
3. Your browser gets the SSE and refreshes itself
4. profit

That's it. No webpack. No node_modules. No existential crisis. Just pure, minimal, live-reloading joy.
