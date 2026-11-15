---
name: plans
description: Use when writing a plan in a project's docs/plans/, changing one, or building a phase of one. Read it before starting, not after.
---

# Plans

**A new plan starts from [`template.md`](template.md)**, keeping its order and
its standing lines word for word. A plan written before it keeps its own
shape when changed.

**A plan lives in the project it was asked for in**, whichever projects it
covers. It is `docs/plans/{name}.md` until it cannot be read whole in one go,
then a directory of that name: its decisions and parameters move to
`decisions.md` first, then each phase to `phase-{number}-{title}.md`, and the
rest stays in `README.md`, whose Status table links to each phase's file.

**The opening tells no history.** Progress is the Status table's, and what
changed on the way sits under the decision or the phase it changed.

**A decision keeps its number**: one reopened is amended where it stands, with
the date, and a new one takes the next. Once one is chosen, every line that
follows from it is rewritten.

**A phase is whole**: what it touches, its tests, its doc lines and its check
sit under it, so whoever builds it reads all of the plan but the other phases.

**Every claim says how it is known**: the file or source it names, or `(Ran)`
or `(Read)` with an entry in that section, or `⚠ verify` until it has one. A
`⚠ verify` tried since is struck through where it stands, followed by what it
showed, so its number still points at it.

**A plan that says a built phase is committed is the caller asking for it**:
commit the phase when it is finished, unless they hold it.
