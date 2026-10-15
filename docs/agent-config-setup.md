# Agent configuration setup

Live files are the source of truth. The repository's `home/` tree is a review
mirror; the existing mise workflow handles machine restoration separately.
The shared mirror target list is `home/.config/mise/config.toml`.

## Refresh the mirror

From the repository root, with Python 3.11 or newer:

```sh
bash scripts/sync-agent-configs.sh --dry-run
bash scripts/sync-agent-configs.sh --apply
git diff --stat
git status --short
```

Review added files as well as tracked diffs before staging. The command never
commits or publishes. Deletions require an explicit `--delete`; review the
preview and approve removals before using that option. Missing sources preserve
their mirrors. Files outside the target list are not managed by this command.

## Adopt Codex preferences

[config.example.toml](../home/.codex/config.example.toml) is a small, manually
maintained example derived from the live model preferences. Compare it with
`~/.codex/config.toml` and merge only the desired keys; do not overwrite the live
file. The example is not an automatically loaded config layer or an include.
Choose a model available to the destination account and client.

The optional Notion block forwards the **name** `NOTION_TOKEN` through `env_vars`.
Provide its value through the local environment or a secret manager before
starting Codex. Ensure the actual launching process receives that environment;
a desktop launch may differ from a terminal launch. Never copy the live MCP
`env` table into the public repository. The meaning of `env_vars` is documented
in the [official configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference).

Keep authentication, project trust, generated MCP runtime entries, permissions,
hook approval state, avatar selection and local plugin installation paths on the
machine. This example does not change any of them. The raw live Codex config
and Claude settings are excluded from automatic mirroring; publish any future
preferences through separately reviewed examples.

## Agents and hooks

Review the mirrored instructions and scripts before restoring or enabling them.
The inspected live config contained no `[agents]` role declarations. If explicit
roles are later added, use a reviewed TOML role file and a relative
`agents.<name>.config_file` path, which resolves relative to the declaring config
file ([official reference](https://learn.chatgpt.com/docs/config-file/config-reference)).
Do not assume Markdown agent files can be used as TOML configuration layers.

The inspected live `hooks.json` used absolute home paths in all command handlers.
It is therefore deliberately excluded from the mirror. On a new machine, create
or merge a local `~/.codex/hooks.json` after reviewing each command, adapting its
paths, checking its interpreter and other dependencies, and confirming the files
it reads or writes. Restoring scripts alone does not register hook handlers.

Codex accepts hooks in `hooks.json` or inline config tables. Avoid registering
the same hooks in both: Codex loads both representations when present in one
layer ([official advanced configuration](https://learn.chatgpt.com/docs/config-file/config-advanced)).
Review hook trust on the destination machine instead of copying persisted trust
hashes. Hook support varies by execution environment; check the
[official hooks guide](https://learn.chatgpt.com/docs/hooks) for the client in use.

## Plugins and machine restoration

Plugin caches and installation state are not mirrored. Reinstall plugins from
their verified original catalog or repository on the destination machine and
reconnect accounts there. Record the source and version only after verifying
them; this guide does not infer installation sources from cache directory names.

New mirror targets do not automatically update the live mise configuration.
Merge the corresponding reviewed tracking entries into the live configuration
before relying on the existing mise restoration workflow. Mirror exclusions do
not configure mise's separate tracking behavior: inspect any directory selected
for tracking for generated files or private content before enabling it.
