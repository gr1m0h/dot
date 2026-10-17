---
name: pr-review-respond
description: Verify existing PR review comments, apply justified local fixes, and draft replies. Do not post or resolve threads automatically.
---

# Address PR Review Feedback

## Orient

Identify the repository, PR URL, head branch, and local working state with available GitHub tools or `gh` and Git. Attach the PR to this chat when supported. Read repository instructions before editing. Do not switch branches, pull, reset, or discard local work automatically; preserve unrelated changes and choose a suitable checkout with the user when needed.

Fetch full inline comments, review bodies, and relevant discussion, including pagination. Track comment IDs and thread context. Skip resolved threads only when their resolution state was actually retrieved; label unavailable state as unknown. Evaluate bot feedback on evidence rather than author identity.

## Decide and fix

- Read the current source and relevant tests or documentation for each comment. Verify whether the concern still applies to the current PR head.
- Classify each request as fix, no change, or discussion needed, with an evidence-backed explanation and honest confidence. Do not turn a numerical threshold into permission to make an architectural decision.
- For approved local fixes, re-read files immediately before editing and make focused changes. Follow the repository's spec and batch-edit checkpoints. Avoid unrelated cleanup.
- Run checks appropriate to the changed behavior and report their actual result. Do not claim that CI passed based on local tests.
- When the user wants to implement the fix themselves, explain the concern and offer staged hints; let the user implement the fix.

## Deliver

Provide a compact decision table with comment/thread ID, location, disposition, evidence, and action. Show complete draft replies grouped by thread, matching the discussion language. State only changes and checks actually completed; do not invent commit references.

Replies are drafts for the user. Do not post comments, submit reviews, or resolve threads without an explicit user request for that action in the current turn. Do not push, create a PR, or edit its metadata unless explicitly requested. Never force-push without explicit approval.

## Evidence-to-action trace

Tie each comment to the current source/diff, the verified premise, the minimal action, and the actual check/result. Distinguish outdated comments from unresolved concerns. Avoid invented confidence percentages or commit IDs. Draft replies must state only work actually completed.

Sources: [GitHub review comments API](https://docs.github.com/en/rest/pulls/comments) for comment/thread fields; the user's instructions define the posting boundary. Verify current API documentation before relying on an unfamiliar field.
