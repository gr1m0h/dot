module.exports = {
  disableEmoji: false,
  format: "{type}: refs {ticket} {subject}",
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
  questions: ["type", "ticket", "subject"],
  scopes: [],
  types: {
    chore: {
      description: "ソース、テストコードに変更を含まない雑多なコミット(ライブラリ変更など)",
      value: "chore",
    },
    revert: {
      description: "revertコミット用",
      value: "revert",
    },
    ci: {
      description: "`.gitlab-ci.yml`をはじめとするCIの手順や変数に関する変更",
      value: "ci",
    },
    docs: {
      description: "ドキュメントに関する変更",
      value: "docs",
    },
    feat: {
      description: "新機能や既存機能の変更、および既存機能の削除",
      value: "feat",
    },
    fix: {
      description: "不具合の修正",
      value: "fix",
    },
    perf: {
      description: "パフォーマンス改善のための変更",
      value: "perf",
    },
    refactor: {
      description: "コミット前後で動作に影響を与えないリファクタリング",
      value: "refactor",
    },
    style: {
      description: "`go fmt` などコードの体裁に関する変更",
      value: "style",
    },
    test: {
      description: "テストコードの追加、変更",
      value: "test",
    },
    build: {
      description: "`Dockerfile`などビルド手順、外部依存に関する変更",
      value: "build",
    },
  },
};
