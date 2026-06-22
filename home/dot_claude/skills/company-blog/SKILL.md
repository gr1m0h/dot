---
name: company-blog
description: Turn a finished case (case-reflect / sreaas report output) into a generalized, confidentiality-scrubbed company tech-blog draft. Use when the user says "会社ブログ", "テックブログ", "案件を記事化", "company blog", or wants to asset-ify case outcomes for public publishing. Realizes the company-blog stage of learn_cycle.md.
triggers: ["会社ブログ", "テックブログ", "案件を記事化", "company blog", "案件をブログに", "成果を一般化"]
user-invocable: true
allowed-tools: Read, Write, Edit, Grep, Glob, WebFetch, WebSearch
---

# /company-blog — Case outcome → generalized company tech-blog draft

Bridge a completed case into a publishable **company** tech-blog draft: take the case's
internal record, **strip customer-confidential details**, generalize the specifics into
reusable technical knowledge, and draft it in good Japanese. This is the company-blog stage
of `~/learn_cycle.md` (案件単位・成果の資産化・機密確認込み).

Personal blog (small, fresh, during-case) is `/write-article`'s job — keep the two distinct:
company blog = case asset, generalized, team voice; personal blog = freshness, small scope.

## 1. Gather the source material
1. If the user names a file/case → read it.
2. Look for case records: `ls -t ~/cases/*.md ./cases/*.md 2>/dev/null | head` (case-reflect output),
   and any `/sreaas:task report` summaries the user points to.
3. If nothing concrete, ASK for the case record or a short brief. Never invent the case.

## 2. Confidentiality scrub (CRITICAL — do this before drafting, and re-check at the end)
Remove or generalize anything that identifies the customer or exposes internals:
- Customer/company names, project codenames, person names → generic ("ある企業", "あるチーム")
- Internal hostnames, URLs, repo names, account/org IDs, ARNs, IPs, ticket IDs → omit or genericize
- Secrets/credentials of any kind → never include (hooks also block these)
- Customer-identifying metrics/scale/dates that, combined, deanonymize the case → blur or drop
- Internal-only tool names or processes that are not public → generalize or omit
Default to removal when unsure. Collect every scrub decision into a checklist for §5.
This aligns with the user's security rules — treat confidentiality as deny-by-default.

## 3. Generalize (case-specific → reusable knowledge)
- Reframe "what we did for customer X" as "a pattern/technique applicable broadly".
- Lead with the problem shape and the reusable decision/principle, not the customer story.
- Keep concrete technical substance (configs, queries, architecture) ONLY where it carries no
  confidential signal; otherwise reconstruct a representative, non-identifying example.
- Ground technical claims in primary sources (official docs / source) via WebFetch/WebSearch;
  cite them. Do not assert behavior without a verifiable source (the user's Verification rule).

## 4. Draft (good Japanese, team voice)
- Output language: Japanese. **Voice: 私たち / チーム** (company blog), です・ます調.
- Follow the structure patterns and the **k16shikano 文章規範** defined in
  `skills/write-article/SKILL.md` (one source of truth — do not duplicate it here):
  one sentence per line, sparse bold, no LLM-ish phrasing, headings H1–H3 only,
  concrete and specific over vague. Apply the 課題解決型 (Pattern B) structure by default.
- Figures/screenshots as placeholders (`[ここに図: 〜]`); never paste real internal screenshots.

## 5. Output + mandatory confidentiality review
- Write the draft to a file (ask for path, else `~/cases/blog-drafts/<slug>.md`).
- Append a **機密レビュー・チェックリスト** the user MUST sign off before publishing:
  list every scrubbed/generalized item and any residual risk you are unsure about.
- State clearly: this is a draft requiring (a) the user's confidentiality review and, per
  learn_cycle.md, (b) customer confirmation where the case is customer-specific. Never publish.
- Suggest the next cycle step: customer confirmation → publish; and that a smaller, fresher
  angle can become a personal-blog post via `/write-article`.
