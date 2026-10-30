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

## An extraction stands for one fact

Every extraction moves something out of the reader's sight. That is worth it
only when the call says enough that they need not look: extract one concept the
domain already has, and leave the rest stated at the call site. Bundling
unrelated steps, or extracting only because code repeats, hides what the call
site said plainly. This holds for specs as much as for code.

## Fewer lines is not a reason

Line count is paid once by whoever writes it and never by anyone reading;
legibility at the call site is paid back on every read.

A refactor whose case rests on how much shorter the result is has measured the
wrong thing. Find the reason that isn't length, or leave the code alone.
