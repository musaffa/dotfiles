---
name: design-principles
description: Use when deciding how code should be shaped rather than what it should do — designing something new, restructuring what exists, extracting or collapsing something, or reviewing a design for its structure.
---

# Design principles

## Prefer composition over inheritance

A class that needs another's behaviour holds it and calls it, rather than
inheriting it.

Inherit only where the parent is the whole of what the child is and the child
adds nothing other code calls.

## An extraction names one fact

What a reader has to open something else to learn, they no longer know where
they are reading. A name standing for several unrelated facts — a helper
bundling four validations, a shared example asserting five routes — takes what
the call site stated plainly and puts it behind a lookup.

Extract where the thing extracted has a name of its own in the domain, and
leave the call site to state the rest. This holds for specs as much as for the
code they cover.

## Fewer lines is not a reason

Line count is paid once by whoever writes it and never by anyone reading;
legibility at the call site is paid back on every read.

A refactor whose case rests on how much shorter the result is has measured the
wrong thing. Find the reason that isn't length, or leave the code alone.
