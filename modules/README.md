# Modules

A module is a stack-specific overlay. The Wolfe core must still make sense if you delete this directory.

A module may add:

1. Extra keys for the site contract.
2. Application pins with checksums.
3. Playbooks and tools for that stack.
4. A short handbook note.
5. Example prompts that only apply when the module is loaded.

It may not change the tenets. It may not add a service.

`community` is the first fully worked module: phpBB, with optional MediaWiki.

To load a module, put its name in `MODULES` in `site/site.env`.
