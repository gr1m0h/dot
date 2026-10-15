"""Fixture tests; never touch live user configuration."""

import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location(
    "sync_agent_configs", Path(__file__).with_name("sync-agent-configs.py"))
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)


class SyncTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name).resolve()
        self.source, self.destination = root / "source", root / "destination"
        self.entry = Path(".agents/skills")
        for base in (self.source, self.destination):
            (base / self.entry).mkdir(parents=True)

    def write(self, base, name, content="example"):
        path = base / self.entry / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def test_add_update_delete_without_writes(self):
        self.write(self.source, "new/SKILL.md")
        old = self.write(self.destination, "changed/SKILL.md", "before")
        self.write(self.source, "changed/SKILL.md", "after")
        self.write(self.destination, "removed/SKILL.md")
        changes = dict(sync.plan(self.source, self.destination, [self.entry]))
        self.assertEqual(set(changes.values()), {"ADD", "UPDATE", "DELETE"})
        self.assertEqual(old.read_text(), "before")
        self.assertFalse((self.destination / self.entry / "new").exists())

    def test_runtime_files_are_neither_copied_nor_deleted(self):
        for name in ("x/auth.json", "x/.env", "x/memory/data.md", "x/cache/data.md",
                     "x/history.jsonl", "x/state.sqlite-wal", "x/settings.local.json",
                     "x/.git/config", "x/.git/objects/example", "x/.hg/store/data",
                     "x/.svn/wc.db"):
            self.write(self.source, name)
            self.write(self.destination, name, "preserve")
        self.assertEqual(sync.plan(self.source, self.destination, [self.entry]), [])

    def test_missing_source_preserves_mirror(self):
        entry = Path(".codex/AGENTS.md")
        (self.destination / entry.parent).mkdir()
        (self.destination / entry).write_text("preserve")
        self.assertEqual(sync.plan(self.source, self.destination, [entry]), [])

    def test_source_and_destination_symlinks_rejected(self):
        self.write(self.source, "x/SKILL.md")
        link = self.destination / self.entry / "x"
        link.symlink_to(self.source / self.entry / "x", target_is_directory=True)
        with self.assertRaises(ValueError):
            sync.plan(self.source, self.destination, [self.entry])
        link.unlink()
        self.write(self.source, "original.md")
        (self.source / self.entry / "link.md").symlink_to("original.md")
        with self.assertRaises(ValueError):
            sync.plan(self.source, self.destination, [self.entry])

    def test_raw_settings_and_root_tracking_rejected(self):
        config = {"dotfiles": {"~/.codex/config.toml": {"mode": "track"},
                               "~/.codex/rules/default.rules": {"mode": "track"},
                               "~/.codex/AGENTS.md": {"mode": "track"}}}
        self.assertEqual(sync.targets(config), [Path(".codex/AGENTS.md")])
        for name in ("~/.codex", "~/.codex/../auth.json"):
            with self.assertRaises(ValueError):
                sync.targets({"dotfiles": {name: {"mode": "track"}}})

    def test_apply_preserves_deletions_unless_explicit(self):
        added = self.write(self.source, "new/SKILL.md", "new")
        added.chmod(0o755)
        self.write(self.source, "changed/SKILL.md", "after")
        changed = self.write(self.destination, "changed/SKILL.md", "before")
        stale = self.write(self.destination, "removed/SKILL.md")
        changes = sync.plan(self.source, self.destination, [self.entry])
        sync.apply_changes(self.source, self.destination, changes)
        self.assertEqual(changed.read_text(), "after")
        self.assertEqual((self.destination / self.entry / "new/SKILL.md").stat().st_mode & 0o777, 0o755)
        self.assertTrue(stale.exists())
        remaining = sync.plan(self.source, self.destination, [self.entry])
        self.assertEqual(remaining, [(stale.relative_to(self.destination), "DELETE")])
        sync.apply_changes(self.source, self.destination, remaining, delete=True)
        self.assertFalse(stale.exists())
        self.assertEqual(sync.plan(self.source, self.destination, [self.entry]), [])

    def test_parent_file_conflict_detected_before_apply(self):
        self.write(self.source, "new/SKILL.md")
        self.write(self.destination, "new")
        with self.assertRaises(ValueError):
            sync.plan(self.source, self.destination, [self.entry])

    def test_root_filter(self):
        config = {"dotfiles": {"~/.claude/CLAUDE.md": {"mode": "track"},
                               "~/.codex/AGENTS.md": {"mode": "track"}}}
        self.assertEqual(sync.targets(config, "claude"), [Path(".claude/CLAUDE.md")])

    def test_broken_source_symlink_rejected(self):
        entry = Path(".codex/AGENTS.md")
        (self.source / entry.parent).mkdir()
        (self.source / entry).symlink_to("missing")
        with self.assertRaises(ValueError):
            sync.plan(self.source, self.destination, [entry])


if __name__ == "__main__":
    unittest.main()
