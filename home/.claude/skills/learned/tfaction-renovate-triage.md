---
name: tfaction-renovate-triage
description: Renovate PR が tfaction/OpenTofu の CI で失敗したのにログに明確なエラーが出ていないときの原因診断。「Renovate PR が CI で落ちた」「tfaction が fail」「renovate-change ラベル」「lockfile OOM」「required_version で CI が落ちる」などで起動。
---

# tfaction × Renovate CI 失敗トリアージ

**Extracted:** 2026-08-08（retro-learn 2026-08-06 の learning flag より・出現 103+ セッション）
**Context:** OpenTofu + tfaction + Renovate 構成の IaC リポジトリで、Renovate 由来 PR の CI が失敗したとき

## Problem

Renovate PR の tfaction CI 失敗は、原因がジョブログに出ず PR コメント側に出る（ログ上は無言の `exit 1` に見える）ため、原因を特定できないまま再実行を繰り返しがち。

## Solution

以下 3 大原因を順にチェックする:

1. **renovate-change ラベル欠如** — plan 差分がある Renovate PR は `renovate-change` ラベルがないと fail する安全機構。エラーはジョブログではなく PR コメントに出る。
2. **required_version の Terraform/OpenTofu バージョン混同** — Renovate は Terraform の最新版で `required_version` を更新するが、OpenTofu は別バージョン体系（1.15.x は OpenTofu に存在しない）。さらに **OpenTofu 1.12 以降は required_version 違反がエラーにならない**ため、CI が通っていても設定が不正な可能性がある。
3. **lockfile バージョン断片化** — 多数の WD で provider バージョンが断片化していると、Renovate ジョブが多バージョン同時解決で OOM して fail する。

## 対処

- ラベル欠如 → `renovate-change` を付与
- lockfile 断片化 → main 側でバージョンを統一してから再実行
- required_version 混同 → `renovate.json5` の該当更新設定を OpenTofu バージョン体系に固定する

## When to Use

Renovate（bot）由来の PR が tfaction / OpenTofu の CI で失敗し、ジョブログに明確なエラーが出ていないとき。まず PR コメントを読み、上記 3 点を順に潰す。
