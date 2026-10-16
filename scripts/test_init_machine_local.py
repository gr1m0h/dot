"""Machine-local provisioning tests, isolated from live configuration."""
import os
from pathlib import Path
import subprocess
import tempfile
import tomllib
import unittest

ROOT = Path(__file__).resolve().parent.parent


class MachineLocalTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dot local ")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.env = dict(os.environ, HOME=str(self.home))
        self.env.pop("XDG_CONFIG_HOME", None)

    def initialize(self):
        subprocess.run(["sh", str(ROOT / "scripts/init-machine-local.sh")],
                       env=self.env, check=True, capture_output=True)

    def test_create_empty_files_and_preserve_edits_on_rerun(self):
        self.initialize()
        paths = [self.home / ".Brewfile.local",
                 self.home / ".config/mise/conf.d/local.toml",
                 self.home / ".config/macos.local.sh"]
        for path in paths:
            self.assertEqual(path.read_bytes(), b"")
            path.write_text("# local customization\n")
        self.initialize()
        for path in paths:
            self.assertEqual(path.read_text(), "# local customization\n")

    def test_custom_config_directory_and_dangling_symlink_preserved(self):
        config = self.home / "custom config"
        self.env["XDG_CONFIG_HOME"] = str(config)
        link = self.home / ".Brewfile.local"
        link.symlink_to(self.home / "missing")
        self.initialize()
        self.assertTrue(link.is_symlink())
        self.assertFalse((self.home / "missing").exists())
        self.assertTrue((config / "mise/conf.d/local.toml").is_file())
        self.assertTrue((config / "macos.local.sh").is_file())

    def test_brew_common_and_local_manifests_are_optional(self):
        config = tomllib.loads((ROOT / "home/.config/mise/config.toml").read_text())
        task = config["tasks"]["setup-packages"]["run"]
        bindir = self.home / "bin"
        bindir.mkdir()
        brew = bindir / "brew"
        brew.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$HOME/brew-calls"\n')
        brew.chmod(0o755)
        self.env["PATH"] = str(bindir) + os.pathsep + self.env["PATH"]
        for common, local in [(False, False), (True, False), (False, True), (True, True)]:
            for name, present in [(".Brewfile", common), (".Brewfile.local", local)]:
                path = self.home / name
                if present:
                    path.touch()
                else:
                    path.unlink(missing_ok=True)
            log = self.home / "brew-calls"
            log.unlink(missing_ok=True)
            subprocess.run(["bash", "-c", task], env=self.env, check=True,
                           capture_output=True)
            expected = (["bundle --global"] if common else [])
            if local:
                expected.append(f"bundle --file={self.home}/.Brewfile.local")
            self.assertEqual(log.read_text().splitlines() if log.exists() else [], expected)

    def test_macos_local_hook_is_optional_and_propagates_failure(self):
        config = tomllib.loads((ROOT / "home/.config/mise/config.toml").read_text())
        task = config["tasks"]["setup-macos"]["run"]
        hook = task[task.index('local_macos='):task.index('echo "Restarting affected')]
        command = ["bash", "-euo", "pipefail", "-c", hook]
        subprocess.run(command, env=self.env, check=True, capture_output=True)
        directory = self.home / "custom config"
        directory.mkdir()
        self.env["XDG_CONFIG_HOME"] = str(directory)
        script = directory / "macos.local.sh"
        script.write_text('printf applied > "$HOME/local-applied"\n')
        subprocess.run(command, env=self.env, check=True, capture_output=True)
        self.assertEqual((self.home / "local-applied").read_text(), "applied")
        script.write_text('exit 23\n')
        result = subprocess.run(command, env=self.env, capture_output=True)
        self.assertEqual(result.returncode, 23)


if __name__ == "__main__":
    unittest.main()
