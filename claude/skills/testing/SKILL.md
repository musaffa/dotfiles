---
name: testing
description: Use when writing or reviewing a test, or deciding whether to write one at all — what to assert, which layer to assert it from, and what the test costs to run. Read it while making those choices, not after the test is green.
---

# Testing

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

Where the only input that breaks a rule is one of those, the layer you are
testing from is the wrong one to assert it from. Cover the rule where it
lives, or leave it uncovered and say so.

### If only an expensive test would cover it, ask

A long wait, new fixture machinery, a change made to the code for the test's
sake — say what it costs and wait.

Writing it unasked spends everyone's minutes on every future run. Dropping the
coverage silently is worse.
