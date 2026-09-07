---
name: testing
description: Use when writing or reviewing a test, or deciding whether to write one at all — what to assert, which layer to assert it from, and what the test costs to run. Read it while making those choices, not after the test is green.
---

# Testing

## What a test asserts

### A test that cannot fail is not a test

Break the behaviour it covers, in the file or in your head. If the test still
passes, it asserts nothing and will go on asserting nothing.

The usual way to write one by accident is to let the setup do the asserting — a
factory that already puts the record in the state under test, a stub returning
the value being checked, a fixture carrying the total the code should compute.

### Assert the behaviour, not the way it is reached

What was returned, what was written, what the caller can see afterwards. Not
which method was called, in what order, with which arguments.

A test pinned to the route has its failures backwards: it breaks on refactors
that changed no behaviour, and holds through the regression it was written to
catch.

### The refusals are where the rules live

A test that walks only the success path proves the code can succeed, which was
never in doubt. The rules are in what it turns down — the validation that
rejects, the guard that raises, the permission that denies.

Assert the refusal and its reason. A test satisfied by any failure keeps
passing once the code fails for a different one.

### Assert a rule where the rule lives

A rule has one home. Asserting it from further out tests everything in between
as well, so the test breaks for reasons that have nothing to do with the rule
and says less when it does.

Where covering one rule means reaching through layers to get at it, move the
test rather than write it.

## What a test costs

### Break a rule with the smallest input that breaks it

An empty string where one is required, a `-1` where the rule says non-negative,
a duplicate of a value already taken — each asserts a validation runs as well
as a hundred-thousand-character string does, at none of the cost. Reach for
whichever the rule under test refuses most cheaply.

Where the field has no rule to break, that is worth fixing where the rules
live, not working around in the test.

### A test whose input is enormous does not get written

Size is the tell, whatever the shape — a string, a batch, a seeded list, a
file, a loop count. It buys one boolean and charges every future run for it.

Where no smaller input and no better layer will break it, do not write the
test. Say which rule that leaves uncovered, and move on without asking.

### If only an expensive test would cover it, ask

A long wait, new fixture machinery, a change made to the code for the test's
sake — say what it costs and wait.

Writing it unasked takes the caller's decision — the cost may well be worth
paying, and they are the one who can say. Dropping the coverage silently is
worse.
