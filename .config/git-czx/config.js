module.exports = {
  disableEmoji: false,
  format: "{type}: {subject}",
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
  questions: ["type", "subject", "body"],
  types: {
    feat: {
      description: "新機能や既存機能の変更、および既存機能の削除",
      value: "feat",
    },
    fix: {
      description: "不具合の修正",
      value: "fix",
    },
    docs: {
      description: "ドキュメントに関する変更",
      value: "docs",
    },
    test: {
      description: "テストコードの追加、変更",
      value: "test",
    },
    style: {
      description: "`go fmt` などコードの体裁に関する変更",
      value: "style",
    },
    refactor: {
      description: "コミット前後で動作に影響を与えないリファクタリング",
      value: "refactor",
    },
    perf: {
      description: "パフォーマンス改善のための変更",
      value: "perf",
    },
    build: {
      description: "`Dockerfile`などビルド手順、外部依存に関する変更",
      value: "build",
    },
    ci: {
      description: "CIの手順や変数に関する変更",
      value: "ci",
    },
    chore: {
      description:
        "ソース、テストコードに変更を含まない雑多なコミット(ライブラリ更新など)",
      value: "chore",
    },
    revert: {
      description: "revertコミット用",
      value: "revert",
    },
  },
};
