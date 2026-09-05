---
name: comments
description: Use when writing or reviewing a code comment, or deciding whether a line needs one at all — the default is none, and this is what the exceptions look like. Read it while writing the code, not in a pass afterwards.
---

# Comments

## The default is no comment

Write none. Then write one for either of two reasons.

A reader would misread the code's intent without it — a reason, an invariant, a
quirk imposed from outside the file.

Or the code *is* a concept the codebase does not have yet: a new piece of the
domain, or an existing one stretched to cover a case it did not before. The
vocabulary arrives with the code, so there is nothing to look up and nowhere
else the meaning is written down. Say what the concept is and what it is for,
once, at the top of whatever carries it — the class, the module, the migration,
the constant a rule is keyed by — in the domain's own words, and let the code
below be read in those terms. A reader landing there should not have to open
`docs/`, another file, or a caller to find out what the thing is.

Everything else is cost with no return: a read for the reader, context for the
next agent, and one more line that can go out of date.

## Why, never what

`# iterate over paying customers` above `paying_customers.map` is a second
description of a line that already described itself, and it will be wrong
before the line is.

Write what a reader cannot recover by reading: why this shape and not the
obvious one, what breaks if the order changes, which constraint outside this
file is being obeyed. Write it to someone fluent in the language who has never
seen this codebase — they do not need a `for` loop explained, they need to know
what the loop is protecting against.

## Plain English, not a second implementation

Say it the way you would to a colleague away from the keyboard. A comment in
the vocabulary of the implementation — class names, method chains, the shape of
the data — re-encodes the screen in the harder notation of the two: the reader
who could follow it did not need it, and the reader who needed it cannot follow
it. Domain names are the exception; they are what the concept is called.

## A comment is not the session's reasoning

The pull mid-change is to explain the change — what it replaced, what was
decided in this conversation. Every such comment is written from the vantage of
one session, and the reader arrives at a file holding several, none agreeing on
what the code is for.

State the standing fact: not "changed to a savepoint so the batch below can
fail", but why a savepoint is what this needs. No ticket references, no dates,
no "now uses", no "previously" — the commit message and `docs/` hold what the
change was about.

## Where it is genuinely hard, spend the lines — and work an example

The default of none is about lines that explain themselves, not a budget hard
code has to fit inside. Where a rule has interacting cases, or the concept is
one the reader has not met, a short paragraph is allowed — and what makes it
land is a worked example in plain English:

```ruby
# Accepted is what was ordered less what never made it: an order of 100 with 3
# lost and 2 rejected accepts 95, and it is the 95 that becomes stock while the
# forecast still moves on the 100.
```

Use values the code really produces, since the example is what a reader checks
themselves against. It can also be the scenario the concept applies in, or the
case that makes the obvious reading wrong — still the concept, never a trace of
the lines below.

## Before writing one, try the other two homes

A block that needs explaining often needs a name: extract it, or rename the
variable, and the explanation travels to every call site instead. A reason big
enough to want a paragraph usually belongs in `docs/` or the commit message,
where it is read before the code rather than found inside it.

A comment is for what is too small and too local for either — or for where
restructuring would widen the change past what was asked, in which case write
the short comment and propose the restructuring on its own.

## A stale comment is a bug, and editing near one makes it yours

When a change makes a nearby comment wrong, fixing it is part of that change.
A comment contradicting the code is worse than none: it is believed once, and
then none of the others are.

If its claim can no longer be checked against the code, delete it — unless it
records a known issue. A bug, a workaround, a limitation, a gap left open is
usually its own only record, and being uncheckable is half of why it was
written. Rewrite one to the standing fact freely; **ask before taking the fact
away.**

## Never comment out code — and ask before deleting it

Do not comment code out. The history has it. A commented-out block does not say
whether it is coming back, and the deletion at least does not pretend to.

One somebody else left is a question rather than a deletion: it is disabled for
a reason the block itself does not carry. **Ask**, saying what it would do if it
ran and whether it still works. Deleting it, fixing it, and leaving it alone are
three different jobs, and which one is wanted is the caller's to choose.

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
