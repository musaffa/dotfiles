---
name: comments
description: Use when writing or reviewing a code comment, or deciding whether a line needs one at all — the default is none, and this is what the exceptions look like. Read it while writing the code, not in a pass afterwards.
---

# Comments

## The default is no comment

Write none. Then write one for either of two reasons.

A reader would misread the code's intent without it — a reason, an invariant, a
quirk imposed from outside the file.

Or the code is introducing a concept the codebase does not have yet: a new
piece of the domain, or an existing one stretched to cover a case it did not
before. That one is the easier to miss. The vocabulary arrives with the code,
so there is nothing for the reader to look up and nowhere else the meaning is
written down. Say what the concept is and what it is for, once, where it is
introduced — on the class, the module, the migration — and let the code below
be read in those terms.

Everything else is cost with no return: a read for the reader, context for the
next agent, and one more line that can go out of date.

## A comment is not the session's reasoning

The strongest pull when writing a comment mid-change is to explain the change —
why this was just done, what it replaced, what was decided in this
conversation. Every such comment is written from the vantage of one session,
and the reader arrives at a file holding several of them, none agreeing on what
the code is for.

The comment belongs to the code, not to the change that touched it. State the
standing fact: not "changed to a savepoint so the batch below can fail", but
why a savepoint is what this needs.

No ticket references, no dates, no "now uses", no "previously". The commit
message and `docs/` hold what the change was about; the comment holds what the
code is.

## Why, never what

`# iterate over paying customers` above `paying_customers.map` is a second
description of a line that already described itself, and it will be wrong
before the line is.

What a reader cannot recover by reading: why this shape and not the obvious
one, what breaks if the order changes, which constraint outside this file is
being obeyed.

## Senior to senior

Write to someone who reads the language fluently and has never seen this
codebase. They do not need a `for` loop explained; they need to know what the
loop is protecting against.

## Plain English, not a second implementation

The comment carries the concept and the reason, so write it the way you would
say it to a colleague away from the keyboard — ordinary sentences, the words
the domain already uses.

A comment written in the vocabulary of the implementation — class names, method
chains, the shape of the data — has re-encoded what is on the screen anyway,
and in the harder notation of the two. The reader who could follow that did not
need the comment; the reader who needed it cannot follow it.

Names from the domain are the exception: they are what the concept is called,
and spelling them out in plainer words only loses the reader the thread.

## Needing a comment is usually a smell — unless fixing it grows the task

A block that needs explaining is often a block that needs a name: extract it,
or rename the variable, and the comment goes away with the explanation now
travelling to every call site.

Where doing that would widen the change past what was asked, write the short
comment instead and leave the restructuring to be proposed on its own.

## Give the "why" its own home first

A reason large enough to want a paragraph is a reason that belongs in `docs/`
or in the commit message, where it can be read before the code rather than
found inside it. Reach for a comment for what is too small and too local to
live anywhere else.

## A stale comment is a bug, and editing near one makes it yours

When a change makes a nearby comment wrong, fixing it is part of that change.
A comment contradicting the code is worse than none: it is believed once, and
then none of the others are.

If its claim can no longer be checked against the code, delete it.

## Never comment out code

Delete it. The history has it. A commented-out block does not say whether it is
coming back, and the deletion at least does not pretend to.

## Two examples

Worth its keep:

```ruby
# A savepoint rather than a plain transaction: the batch below is allowed to
# fail without taking the correction above it down.
```

Not:

```ruby
# Wrap in a savepoint and then process each line, updating the status.
```
