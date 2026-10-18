---
name: docs
description: Use when adding to or changing a project's docs — docs/ or the README — or when a plan lists a doc change. The default is no new line. Read it while writing the line, not when planning.
---

# Docs

**Correct the lines a change made wrong.** Behaviour no line describes is not
a reason to write one: the code, its comments and the commit message carry it.

**A new line is a command, a rule the code cannot show, or a trap that fails
silently.** Name which before writing it. If it is none, it belongs in the
commit message.

**A rule a comment already states where the reader meets it is not a doc
line.** Check the comments the change itself added first.

**A plan names a doc change by its line**, never as "a line on X", and the text
is checked against this again when it is written. Approving a plan's code does
not approve its doc line.

**`docs/plans/` is a little more permissive.** A plan is kept current as its
phases land, and records the decisions taken while implementing it. It still
does not describe what the code does or repeat what a comment says.
