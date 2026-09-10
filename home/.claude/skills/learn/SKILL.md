---
name: learn
description: Owner of the personal (human) learning lifecycle — ~/learn/BACKLOG.md and the weekly retro loop. Verbs — (default) show loop status; `add <topic>` capture a learning topic at any moment; `review` process a retro-learn report (pick topics → backlog + last-retro update); `start [topic]` pick a backlog topic and launch /learn-map; `done [topic]` close out a finished exercise. Use when user says "learn", "learn add", "学びに追加", "learn review", "retro のレビュー", "learn start", "学習始める", "learn done", "演習終わった". NOTE: extracting reusable patterns from a session is /reflect (moved 2026-08), not this skill.
argument-hint: "[<none> status · add <topic> · review · start [topic] · done [topic]]"
---

# /learn — Human Learning Lifecycle Owner

This skill owns the *human* learning loop: `~/learn/BACKLOG.md` (topic backlog +
`last-retro:` freshness field) and the procedures around it. Every verb maps to a
lifecycle stage:

```
捕捉 add → 収穫 (auto: hook queues retro-learn → /batch runs it) → 選別 review
→ 変換 start (→ /learn-map) → 実践 (/learn-coach, /mode learning) → 定着 done
```

Boundaries: harness/AI memory is NOT this skill's domain — session-pattern extraction
to `~/.claude/skills/learned/` lives in `/reflect` (absorbed 2026-08); memory persistence
is `/update-memory`. The session-start hook owns auto-queuing (`personal: retro-learn`
when 7 days past `last-retro:`) and the `LEARN_BACKLOG` / retro-state display. `/batch`
just executes the retro task. `/learn-map` / `/learn-coach` stay separate skills (rich
generation/coaching rules + natural-language auto-trigger); `start`/`done` are the thin
lifecycle joints around them.

## Verb: (default, no args) — Status

Read `~/learn/BACKLOG.md` and report in a few lines: unchecked topics (`[ ]`),
in-progress (`[~]`), days since `last-retro:`, and whether a retro-learn report is
waiting in `~/.claude/batch/out/`. Recommend the single next action (review > done > start).

## Verb: `add <topic>` — 捕捉 (ad-hoc capture)

The explicit 口 for capturing a learning topic the moment it appears (a learning flag
worth keeping, a term you couldn't explain, a review comment that exposed a gap) —
no need to wait for the weekly retro.

1. Append to `## Topics` in `~/learn/BACKLOG.md`:
   `- [ ] <topic> — <出所 (この会話/flag/案件 — no client names)> — <一言メモ>`
   If the topic/メモ is thin, infer from the current conversation; ask only if genuinely ambiguous.
2. Do NOT touch `last-retro:` (that field belongs to `review`).
3. Confirm in one line: topic + current backlog count. Capture only — no dispatch, no learn-map.

## Verb: `review` — 選別 (process a retro-learn report)

Run in the main session when a retro-learn report sits in `~/.claude/batch/out/`
(the hook shows "レビュー待ち"). The user picks; Claude writes — the user never edits
these files by hand.

1. Read the report; present 学習題材候補 as a numbered list (with 出所/一言メモ).
   Also present pattern candidates and confirm which to save to `~/.claude/skills/learned/`
   (format owned by `/reflect` §6).
2. User picks numbers (or 全部/なし). If asked "どれがいい？", recommend: topics most
   likely to recur in current work first, smallest first on a tie.
3. Then perform ALL of:
   - ① append picked topics to `## Topics` in `~/learn/BACKLOG.md` (format above)
   - ② set `last-retro:` in that file to today (resets the 7-day auto-queue timer)
   - ③ delete the report from `~/.claude/batch/out/`
   Review is incomplete until ①〜③ all happen — the session-start hook keeps nagging otherwise.
4. Rejected topics are simply dropped; a future retro re-surfaces them only if they recur.

## Verb: `start [topic]` — 変換 (begin a study session)

1. No topic given: list unchecked backlog topics numbered; user picks (recommend as in
   `review` step 2 if asked). Topic given: match it against the backlog (fuzzy OK);
   proceed even if unlisted (and add it as a `[~]` line).
2. Invoke the `learn-map` skill for the chosen topic (it generates `~/learn/<topic-slug>/`
   GUIDE.md + README.md + STRUGGLE_LOG.md and flips the backlog line to `[~]`).
3. Suggest `/mode learning` if not already active; mention `/learn-coach` for when stuck.

## Verb: `done [topic]` — 定着 (close out an exercise)

1. Identify the finished topic (the `[~]` line; ask if several).
2. Read its `STRUGGLE_LOG.md`: summarize what was hard and why in 2-3 lines back to the user.
   Recurring weak spots → propose them as new `add` candidates (input for the next retro round).
3. If the exercise surfaced reusable patterns, hand off to `/reflect` for skill-ification
   (do not duplicate that procedure here).
4. Flip the backlog line to `[x]`. Done = the loop closed for this topic.
