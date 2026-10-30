---
name: naming
description: Use when naming anything in code, in any language — a function or method, a variable or constant, a type, a module, package or file — when reviewing a name, or when changing what something does or holds. Read it while choosing the name, not in a pass afterwards.
---

# Naming

## Write for a reader who sees only the name

Wherever a name is used, the reader sees it and what is around it, not its
definition, and should know from that alone what the thing is or does. The
language and the codebase decide a name's form — its case, its prefixes and
suffixes; what follows is what it says.

- A function or method is named for why it is called: a verb for its action
  when it is called for its effect, whatever it returns; its answer when it is
  called only for that; a question when it answers yes or no.
- A variable, constant, field or parameter is named for what it holds, or,
  holding a yes or no, for the question it answers.
- A type is named for the one thing it is; one that lends an ability to
  others, for that ability.
- A module, package or file is named for what it holds; where the language or
  a tool ties it to a name inside it, it takes that name.

What a type already says stays out of a name; what it cannot say — a unit, a
bound, whether a value is raw or escaped — goes in. Use the domain's word, or
the codebase's where it has one: one concept, one word. An adjective or
participle on its own names a yes or no, and nothing else. A word that would
fit anything, such as data, info, manager, helper, util, handle or process, is
no name where a specific one exists. Nor is history, such as new, old, a
version, fixed or improved, which the next change makes wrong.

A name is wrong if, where it is used, it reads as something else, echoes a
nearby word in another sense, or makes sense only inside the expression it was
written for. Wordplay is never clarity.

A name carries as much as its reach requires. A local read beside its
definition can be brief; a name used away from its definition says everything
except what the code around it already shows. A longer name that says what the
thing is beats a short one the reader has to look behind.

## Spend the time

Try more than one candidate before anything uses the name, and read each
everywhere it will be used; the first that fits often describes how the code
was written rather than what it is. A name that will not come means the thing
does more than one job. A change to what a thing does or holds is a change to
its name: rename it, or say it no longer fits.
