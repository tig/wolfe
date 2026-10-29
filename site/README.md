# Site contract

This directory is the only place an instance binds identity.

The handbook talks about "the origin" and `SITE_DOMAIN`. The tools read `site/site.env`. Nothing else in this repository should hard-code a hostname, an IP, a vault name, or a version pin.

## Bind an instance

```bash
cp site/site.env.example site/site.env
cp site/pins.env.example site/pins.env
```

Edit both files. Replace every `<PLACEHOLDER>` and every `example.org`. `site/site.env` and `site/pins.env` are gitignored. They must stay that way.

If a value is a secret, do not put it here. Put a pointer:

```bash
DB_PASSWORD_ITEM='<VAULT_NAME>/<ITEM_NAME>'
```

The human, or a vault CLI on the host, resolves the item at run time.

## Modules

`MODULES` is a space-separated list of overlays under `modules/`.

`MODULES='community'` loads the phpBB (optional MediaWiki) fragment and pins.

`MODULES=''` is a generic VPS. The core tools still work.

Copy keys from `modules/<name>/site.env.example` into your bound `site/site.env`, or let the tools source the module example on a dry run when no bound fragment exists.

## Pins

`site/pins.env` holds runtime pins that are not application-specific (OS train, language version). Application pins live in the module that owns the application, and are copied into `site/pins.env` or left as `modules/<name>/pins.env` (also gitignored when bound).
