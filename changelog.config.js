module.exports = {
  disableEmoji: false,
  format: "{type}: refs {subject}",
  list: [
    "feat",
    "fix",
    "docs",
    "test",
    "style",
    "refactor",
    "perf",
    "build",
    "ci",
    "chore",
    "revert",
  ],
  maxMessageLength: 64,
  minMessageLength: 3,
  questions: ["type", "subject"],
  scopes: [],
  types: {
    chore: {
      description: "For miscellaneous commits that do not include changes to source code or test code (e.g., library changes)",
      value: "chore",
    },
    revert: {
      description: "For revert commit",
      value: "revert",
    },
    ci: {
      description: "For changes to CI procedures and variables",
      value: "ci",
    },
    docs: {
      description: "For document modification",
      value: "docs",
    },
    feat: {
      description: "For new features, changes to existing features, and deletion of existing features",
      value: "feat",
    },
    fix: {
      description: "For fixing defects",
      value: "fix",
    },
    perf: {
      description: "For changes to improve performance",
      value: "perf",
    },
    refactor: {
      description: "For refactoring that does not affect behavior before and after commit",
      value: "refactor",
    },
    style: {
      description: "For change the appearance of the code",
      value: "style",
    },
    test: {
      description: "For adding or changing test code",
      value: "test",
    },
    build: {
      description: "For changes related to build procedures and external dependencies",
      value: "build",
    },
  },
};
