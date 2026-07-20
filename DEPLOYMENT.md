# Deployment

Oxytone runs on a single DigitalOcean droplet, configured reproducibly with
Ansible (`deploy/`). The playbook **configures an existing droplet** — it does not
create the droplet or DNS. Three services run behind Caddy:

| Service          | Port             | systemd unit    | Runs                            |
| ---------------- | ---------------- | --------------- | ------------------------------- |
| BaseX (JVM)      | 8080 (localhost) | `oxytone-basex` | `basexhttp`                     |
| SvelteKit (Node) | 3000 (localhost) | `oxytone-web`   | `node index.js` (adapter-node)  |
| Caddy            | 80/443           | `caddy`         | reverse proxy + automatic HTTPS |

Caddy routes `/basex/*` → BaseX (prefix stripped), everything else → the Node
server. ufw denies all inbound except 22/80/443, so BaseX (which runs with no auth
password) and Node are never publicly reachable.

The app is shipped from your **local working copy** by rsync: BaseX RESTXQ modules
(`webapp/`), shared XQuery (`repo/`), the ~5 GB prebuilt databases (`data/`), and
the locally-built SvelteKit output (`build/`). Nothing is built on the droplet.

## First-time setup (out of band)

1. Create a droplet (Ubuntu/Debian). Size for ~5 GB of DBs plus the JVM — **≥4 GB
   RAM, ≥25 GB disk**; more disk headroom is safer since `data/` alone is ~5 GB.
2. Point DNS at it: an **A record for `oxytone.xyz` → droplet IP** (required before
   the first deploy, or Caddy's Let's Encrypt issuance fails).
3. Confirm root SSH access: `ssh root@<DROPLET_IP>`.
4. Install the Ansible collections once:
   `ansible-galaxy collection install -r deploy/requirements.yml`
5. `cp deploy/inventory.ini.example deploy/inventory.ini` and fill in the droplet
   IP and your SSH key path (gitignored — it holds host details).
6. `cp deploy/vars.yml.example deploy/vars.yml` and adjust if needed
   (`deploy/vars.yml` is gitignored — the default domain is already `oxytone.xyz`).

## Pre-flight (every deploy)

- [ ] Databases built locally: `just seed` — confirm `data/` holds
      `glaux/ tei/ lsj/ normalized/` (≈5 GB total).
- [ ] `just build-local` succeeds (this also runs as the first step of `just deploy`).
- [ ] `deploy/inventory.ini` points at the droplet; `oxytone.xyz` resolves to it.

## Deploy

```sh
just deploy
```

This runs `just build-local` (builds `build/` with `PUBLIC_BASEX_URL=/basex/` baked
in) then the playbook. The playbook is idempotent: it installs system packages,
Java, Node, BaseX + Saxon, ufw rules, and Caddy; rsyncs the app and databases;
writes systemd units; and gates on health checks (BaseX :8080, web :3000, then
`https://oxytone.xyz/`). A failing gate fails the run rather than proceeding.

The `data/` rsync does **not** delete on the droplet, so the runtime-accumulated
`normalized` render cache survives redeploys.

## Verify

```sh
curl -I https://oxytone.xyz/                 # 200
just status                                  # both units active (running)
just logs-web                                # clean
```

Then smoke-test in a browser at `https://oxytone.xyz/`:

- [ ] A treebank reading page renders (exercises BaseX `read` + Saxon XSLT).
- [ ] A word definition opens (`define`).
- [ ] Flashcard CSV export works (`flashcards.xqm`).

## Rollback

The previous release is whatever `build/` you last shipped. To revert code, rebuild
from a known-good commit and redeploy:

```sh
git checkout <last-good-sha>
just deploy
```

Or SSH in and restart the units after restoring a known-good `build/`:

```sh
ssh root@<DROPLET_IP> 'systemctl restart oxytone-web oxytone-basex'
```

## Notes

- `PUBLIC_BASEX_URL` is baked in at **build time** (`$env/static/public`) — always
  build via `just build-local` (or `just deploy`) so it points at `/basex/`.
- The droplet's `.basex` config is generated with droplet paths by the playbook;
  the local `.basex` (hardcoded to `/home/vincent`) is never shipped.
- Saxon jars are mandatory — without them `read`/`define`/flashcards return 500.
