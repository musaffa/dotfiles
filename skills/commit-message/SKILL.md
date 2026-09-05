---
name: commit-message
description: Use when writing a commit message — what the subject line says, whether the change needs a body at all, and what belongs in one. Read it before drafting the message, not after.
---

# Commit messages

## The subject line is imperative

"Restate an outlet header from the lines it sums", not "Restated" or "Restates".
It completes the sentence "this commit will …".

## A body is the exception, not the shape of a message

Write one only where the change needs it — where the previous code was wrong,
why this shape was chosen over the obvious one, what a reader would otherwise
have to reconstruct from scratch. A body that restates the diff is worse than
none: it costs a read and returns what the reader could already see.

Most commits have no body. That is the normal case, not a message left
unfinished.

## A body is prose, at most two paragraphs

Paragraphs, not a list of what was touched — the diff is already that list.

Two paragraphs is a ceiling, not a target; one is the normal case. A message
running past two means one of two things, and both are worth catching before
the commit lands:

- it is explaining what the diff already says, and the explanation should go, or
- it is several commits wearing one message, and the change should be split

## A body never reports verification

Which specs were run, how many passed, what the linter said — none of it goes
in the message. It is true at the moment of writing and stale by the next
commit, and the person who needs it is the caller in the conversation, not a
reader of the history a year on.

Say it alongside the commit instead.

## Deciding *whether* to commit is not this skill's business

That call belongs to the project's own instructions and to the caller. This
skill covers only what the message says once a commit is being made.
