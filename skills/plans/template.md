<!--
Fill each {slot} and delete each comment. Leave out a section with nothing
to say, but never Status, How to work through it, Decisions or Phases: their
standing lines are read by whoever builds the plan. A line a comment says is
added later is left out until then; anything else stays as worded.
-->

# {What the plan delivers}

This plan {lets | gives | adds | moves …} {whom, what, and how far}. It covers
{the projects it changes}.

Proposed {YYYY-MM-DD}, from {what it was drawn from: the code read, what was
run, the documentation}. {Whether production has ever run for each project it
covers, where that is read, and what follows from it for this plan.} An item
marked **⚠ verify** has not been confirmed here.

## Status

<!-- State: proposed, built {YYYY-MM-DD}, not taken, later. -->

| Phase | What it delivers | State |
|---|---|---|
| [1. {Title}](#1-title) | {What there is once it lands} | proposed |
| [2. {Title}](#2-title) | {…} | proposed |

{The order the phases land in, where it is not one after another.}

**This plan is kept current as its phases land.** The agent finishing a phase
marks it in the table, and lists under the phase what it decided while
building it.

## How to work through it

<!--
The `_templates/` bullet and the scaffolding skill only where the project
scaffolds from one. A constraint that holds in every phase is a bullet here
too.
-->

- **One phase at a time, in order**, unless the lines under the Status table
  say otherwise.
- **Load the skill a step touches before writing it**: `design-principles`
  for a refactor, `testing` for a test, `comments` for a comment, `docs` for
  a doc line, `naming` for a name, and {the project's scaffolding skill} for
  a generator or schema change.
- **A pattern change changes `_templates/` in the same phase**, and a move
  takes its tests along.
- **Ask before deleting code that was unused before the change**, even where
  a phase names it.

## Today

- **{What the code does now, as a statement.}** {Where that is read: the
  file, the constant, the command.}

<!-- A section of the plan's own, where the shape rests on one. -->

## {What it shows}

{The cases a rule has to hold in, what was measured, what others do: a table
where each row is a case.}

<!-- Shape and Edge cases are left out where the phases stand alone. -->

## Shape

{The design as it stands once built, in a paragraph. Then a section for each
part of it.}

### {A part}

- **{A rule of the design.}** {How it holds, and the decision it rests on
  (D1 (a)).}

## Edge cases

- **{What happens at an edge of the shape.}** {What the plan does about it,
  or that it cannot.}

## Decisions

**A phase's open choices are asked, not made.** The agent building a phase puts
each choice its text leaves open to the caller as options before writing what
depends on it. Each is added here once taken, as a decision of its own.

### D1. {What is being decided}

{What makes it a choice, where the options need it said.}

- **(a) {The option.}** {What follows from it, and what it costs.} · {n}/10
- **(b) {The option.}** {…} · {n}/10

**Recommended: (a).** {What makes it better, and what would change that.}

<!-- Added once the caller has chosen. -->

**Chosen: (a)** ({YYYY-MM-DD}). {How, where it was not taken as written, and
which lines were rewritten for it.}

## Parameters to confirm

| Parameter | Proposed | Chosen |
|---|---|---|
| {A name, a number, a message's words} | {The value} | {as proposed, or the value} ({YYYY-MM-DD}) |

## Phases

Each phase leaves {the app | both apps} working. **A phase is committed once
it is built**, unless the caller holds it.

Each rule is asserted where it lives. A phase's **Tests** name the rule, the
file asserting it, and the run the phase ends with. Its **Docs** are the doc
lines the change would make, as they would read. Its **Check** is what is
looked at once it is built, where no test reaches.

### 1. {Title}

{What the phase builds, and the decisions it waits on. Where the plan has no
Shape: what is there today, and what changes.}

**Touches**

<!-- Grouped by project where the plan covers more than one. -->

- `{path}`: {what changes there}
- `{path}`, new

**Tests**

- **{The unit}**, `{the file}`: {the rules asserted there}.
- Ends with {the run and, where it is a whole suite, why}.

**Docs**

<!-- One block per doc line, in the form that fits. -->

`{doc}`, {section}, after {which line}. Adds ({a command | a rule | a trap}):

> {The line as it would read.}

`{doc}`, {section}. Corrects a line the change makes wrong:

> {The line as it reads now.}

becomes

> {The line as it would read.}

**Check**

{Where and how it is looked at: in the image, on staging, by eye.}

<!-- Added once it has been looked at. -->

{What it showed, and when.}

<!--
Added by whoever builds the phase: what followed from the plan and its
decisions. A choice the plan left open is asked, and goes under Decisions.
-->

**Decided while building it**, {YYYY-MM-DD}:

- **{What was decided.}** {What it turned on.}

## Not in this plan

- **{What a reader would expect to find here.}** {Why not, or where it goes
  instead.}

## Cost

- **{What it installs, adds to a request, holds in memory, or asks of a
  deploy.}** {How much, and where that is read.}

## Ran

On {YYYY-MM-DD}, against {the versions}, in {a script that touched no file | a
spec written for it and deleted}:

1. {What it showed.}

## Read

- {The file, or the package and its version}: {the fact read there}.

## ⚠ verify

1. {What the plan assumes and nothing has confirmed.}

<!-- Added once an item is tried, in its place. -->

2. ~~{One tried since.}~~ {What it showed, where, and when.}

## Sources

- {The source, as a link}: {what was read there}
