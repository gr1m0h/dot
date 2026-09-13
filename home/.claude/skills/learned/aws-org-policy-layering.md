---
name: aws-org-policy-layering
description: AWS Organizations の SCP/RCP・IAM trust policy を設計/レビューするときの判断チェックリスト。「SCP を設計」「RCP」「組織ポリシー」「trust policy の Deny」「セッション有効期限を IAM で」などで起動。
---

# AWS 組織ポリシー（SCP/RCP）レイヤリング設計

**Extracted:** 2026-08-08（retro-learn 2026-08-06 の learning flag より・顧客インフラ移行支援 2026-07 複数セッション）
**Context:** AWS Organizations の SCP/RCP や IAM trust policy を設計・レビューするとき

## Problem

SCP/RCP の役割分担・Deny vs Allow の評価順・委任ポリシーの可否を毎回調べ直しになり、trust policy の Deny プレースホルダの置き方を誤って「後から足した Allow が効かない」事故を起こす。

## Solution

以下のチェックリストで判断する:

1. **SCP と RCP の役割分担** — SCP は「org 内プリンシパルの権限上限」、RCP（2024 年末追加）は「org 内リソースへのアクセス上限（外部プリンシパルを含む）」。両方を組み合わせて初めて外部からの不正アクセスまで制御できる。
2. **trust policy のプレースホルダは「成立しない条件付き Allow」で置く** — `Deny: *` をベースにすると後から追加した `Allow` も潰れる（明示 Deny は常に Allow に優先）。代わりに絶対成立しない条件付き `Allow` をプレースホルダにする。
3. **時間/セッション系条件キー** — `aws:CurrentTime` は全リクエストで評価されるためセッション有効期限を動的に実現できる。`aws:TokenIssueTime` の Deny はセッションの即時無効化に使う。一次情報（IAM 条件キーのドキュメント）で評価タイミングを確認する。
4. **委任** — SCP 管理委任ポリシー（2022 年末追加）でメンバーアカウントに SCP 管理を委任できる。

## When to Use

AWS Organizations のポリシー設計・レビュー、IAM trust policy 作成時、「セッション発行後 N 時間で自動無効化」のような時間ベース制御を設計するとき。
