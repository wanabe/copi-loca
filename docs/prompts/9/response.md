Here's a summary of the memos from real-world testing, focusing on feature expansion and usability for the memo feature. Unrelated notes have been omitted.

---

# Memo Feature Expansion & Usability Notes

## Feature Ideas
- Support for git operations:
  - reflog,
  - status (including untracked files),
  - rebase,
  - log,
  - cherry-pick,
  - branch creation/reset,
  - checkout, and
  - log flags (e.g., show only names).
  - Stage/unstage changes by line.
- Add more features about memo:
  - Ability to change the order of memos.
  - Filtering memos by tag and adding tags later for meaningful grouping.
  - Export memos to markdown; append to a single file.
  - Multi-line memos, not just single-line.
  - Bulk delete for memos.
  - Memo editing via dialog.
  - Slack-like threads and replies.
  - Topic switching (like account switching), though changing topics later may feel unnatural.
  - AI summarization of dumped thoughts.
- Whiteboard feature:
  - Mind map visualization using SVG, with parent-child relationships and scrollable/pinch-in support.
  - Predictive conversion based on context.
- File presentation:
  - Prism integration (important).
- Agents.md for tracking agents/tools.

## Usability Observations
- Pagination may be overkill on stimulus.
- Using Opal or WASM is likely overkill and may be slow.
- Offline whiteboard/mind map for personal use is desirable.
- Exporting memos together is useful.
- Most of the time, only the latest memo is needed, not the full history.
- Battery usage is reasonable during memo feature testing.

---

This document summarizes actionable ideas and usability feedback for expanding the memo feature in this Rails application.

