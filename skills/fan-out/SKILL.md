---
name: fan-out
description: Use when a change is big enough to want more than one agent on it — reviewing a diff across the units it touches, planning something structural, or implementing a chosen plan unit by unit. Covers which agent does which job, which model each runs on, what the project has to state for any of it to work, and how to dispatch them. Read it before starting the work, because whether to fan out is decided before the first file is opened, not partway through.
---

# Fanning out across agents

The roster is `~/.claude/agents/`, one file per agent, with one workflow beside
it in `~/.claude/workflows/`. Both are shared by every project on this machine
and name no fact about any of them: what a project is written in, what its
tests run through, and what its tree divides into are the project's to state.
This skill says when to reach for the roster, what each agent is for, and what
a project owes it.

Invoking this skill is the authorisation to call the `Workflow` tool. Nothing
else here is.

## The roster

Each agent's model, effort and tool access live in its own frontmatter, which
is authoritative. Never pass `model:` at a call site — not to the `Agent` tool,
not to `agent()` in a workflow script. A model named in two places is a model
that will disagree with itself later. The table here is documentation, and goes
stale the moment the frontmatter changes; the frontmatter is what runs.

| Agent | Model | For |
|---|---|---|
| `plan-change` | Opus | Reads the docs and the code, dispatching `scout` for the paths, then returns a plan naming the alternatives and recommending one. Never edits |
| `implement` | Sonnet | Writes one already-decided change in one unit. Never commits, never widens, never restructures anything the plan did not pin |
| `review-design` | Opus | Reviews one dimension of one unit, and refutes another reviewer's finding. Reads only; never edits, never runs tests |
| `scout` | Haiku | Locates things. Which units a diff touches, where a symbol lives, which test directories cover a file |
| `verify` | Haiku | Runs the linter and the tests, reports what failed. Fixes nothing |

## What the project has to state

Five facts, stated once in the map doc `AGENTS.md` § Documentation indexes.
They go there rather than into `AGENTS.md` itself because `scout` is the only
agent that reads them and `scout` reads that doc in full already — the map and
the facts are one read, and `AGENTS.md` stays the size it is. What `AGENTS.md`
carries is the index entry, which is the part a subagent has to inherit rather
than fetch, and which therefore says the facts are in there.

| Fact | What asks for it |
|---|---|
| The unit the tree divides into, and where those units live | The whole division of labour below. A tree that divides into none says so, and the fan-out goes by dimension alone |
| Where a unit's tests sit | `scout`, pairing a change with the tests that cover it |
| Which file kinds the project counts as code | The review workflow, deciding whether the code dimensions have anything to read |
| The command that reports style without rewriting it | `verify`. The mode matters: a fix the linter applies is an edit `verify` is not allowed to make |
| The runner a suite-width scope takes, the runner a narrower one takes, and the whole command that runs every test there is | `verify`, and the workflow, which pairs each scope with one by the scope's width |

There is no row for the map itself: the facts are stated in it, so naming it
twice would be one more thing to keep in step. A missing row is not a crash. It
is a Haiku agent at `effort: low` guessing at it, and the guess reaches the
caller looking like an answer. State them.

A map doc carrying commands as well as paths is a doc whose size can run away,
and its size is what makes `scout`'s read cheap. Keep the facts a table of
short rows.

## When it is worth it

A unit that is genuinely self-contained — its own boundary, its own tests — is
what makes any of this worth doing: one agent per unit is a real division of
labour rather than several agents reading the same files. Where a tree has no
such unit, the division is by dimension instead: four agents over one change
rather than four per unit, which is still a fan-out and still worth it on a
change large enough to want one.

**Reviewing a written change** — the workflow below. It scopes itself to the
units the diff touches, so it costs what the change costs.

**Planning something structural** — one `plan-change` agent. A refactor, a
schema change, a new resource, anything crossing a unit boundary. One agent,
not several: a plan is one argument, and three plans is a thing the caller now
has to referee. It dispatches `scout` itself rather than reading the tree with
Opus tokens, so one planner bills as one Opus agent plus some Haiku ones whose
reports never reach you.

**Implementing a chosen plan that spans units** — one `implement` agent per
unit, dispatched together, once the plan is pinned. They must not touch the
same files: where the plan has them sharing one, that part is one agent's job
first and the rest wait. How to dispatch them is
[below](#why-there-is-no-plan-or-implement-workflow).

**Not worth it** for a change inside one resource, a question about how
something works, or anything where dispatching costs more than reading the file
would. `scout` and `verify` are cheap enough to call speculatively; the Opus
agents are not.

## The review workflow

```
Workflow({ scriptPath: '~/.claude/workflows/review-change.js', args: { repo: '/path/to/repo' } })
Workflow({ scriptPath: '~/.claude/workflows/review-change.js', args: { repo: '…', depth: 'deep' } })
Workflow({ scriptPath: '~/.claude/workflows/review-change.js', args: { repo: '…', target: 'master..HEAD' } })
```

**Pass `repo` whenever more than one repository is in reach**, which is any
session holding an additional working directory. A dispatched agent does not
reliably inherit the directory it was dispatched from — checked, not assumed: a
`scout` dispatched from the primary directory and asked to resolve its own
repository root resolved the additional one instead, and went on to read that
project's facts out of that project's `AGENTS.md`. Unnamed, the run reads the
wrong project's unit, lints it with the wrong linter and tests it with the
wrong runner, and every one of those reports cleanly. Leave `repo` out only
where the session has one repository in it.

Pass the path, not `{ name: 'review-change' }` — the name registry holds the
built-in workflows, and a script of your own is reached by the path it sits at.
Expand `~` to the home directory the tool is running under. A script in that
directory is also listed as a skill of its own name, which a session picks up
once it has seen the file.

The path is checked after symlinks are resolved, and the resolved path has to
sit somewhere the session may read: inside `~/.claude` itself, or in a
directory added to `permissions.additionalDirectories` (or by `/add-dir`).
Where `~/.claude/workflows` is a symlink into a dotfiles repository, the
directory it points at is what has to be added — otherwise the run is refused
before it starts, at both the link and the target. That entry takes `~` and
expands it; it does not take `$HOME`, which stays a literal and so grants
nothing, silently and with no error to read.

Defaults to the uncommitted working tree. `depth: 'deep'` raises the refuting
votes per finding from one to three.

It runs `scout` once, to read the project's facts and scope the diff, then
reviews it: `correctness`, `tests` and `design` once per unit touched, and
`conventions` once over the whole change — that last one judges the scaffolding
templates and the docs, which belong to the change rather than to any one unit,
so fanning it out per unit would buy several agents reading the same two
places. Where no code changed at all, only `conventions` runs and the workflow
says so.

Reviews finish before any verification starts. That barrier is the point: every
finding is deduped across dimensions first, so one defect that two reviewers
found under different names costs one refutation instead of two, and only the
twenty most severe survivors are verified. `verify` runs alongside the whole
review rather than gating it, so a whole-tree test run overlaps instead of
queueing. The test scopes it is handed are targets and widths: the script pairs
each with the runner the project named for that width, so the pairing is code
rather than one Haiku agent checking another's at the same effort.

What comes back is already deduped and severity-ordered, with `alsoFlaggedBy`
naming the other dimensions that found the same thing. There is no summarising
agent — the ordering is plain code, and the prose is yours to write.

### What it costs

Reviews are fixed by the scope; verification is capped globally, so the ceiling
is predictable rather than a product. For a change touching `n` units:

- **reviews** — `3n + 1`: three dimensions per unit, plus `conventions` once
  over the whole change. Where no code changed, just the one. Where the tree
  divides into no unit, the three read the whole change and `n` is 1
- **verifiers** — at most 20 at `normal`, 60 at `deep`, whatever `n` is
- **fixed** — two, the scout and the checks agent

| Units touched | `normal` | `deep` |
|---|---|---|
| none (no code changed) | ≤ 23 | ≤ 63 |
| 1, or a tree with no unit division | ≤ 26 | ≤ 66 |
| 2 | ≤ 29 | ≤ 69 |
| 4 | ≤ 35 | ≤ 75 |

Those are ceilings — verification only reaches the cap if the reviewers find
twenty-plus distinct defects. Concurrency is capped at `min(16, cores - 2)`, so
a `deep` run on a wide change is a long wall clock as much as a large bill.

Three things it will not tell you unless you look. `boundaryReach` decides
whether the honest test scope is the whole tree, and it is decided by a Haiku
agent at `effort: low` — which is why it answers in three states rather than
two. `crosses` and `unknown` both buy a run of every test there is, so the
narrow scope is not where a guess lands, and `boundaryReason` beside it says
what decided which. `testsResult` names one of four outcomes rather than clean
or not, because a run cut off partway and a run that matched no tests are
neither passes nor failures, and the empty one is what a boolean used to report
as a pass — `testCount` is the count that tells them apart. And the workflow
logs every finding it dropped at the cap, by `file:line`; a run that logs no
drops verified everything it found.

## Why there is no plan or implement workflow

Both need you in the middle, and a workflow script cannot put you there.

A plan is worth having because you choose between its alternatives — so it ends
by returning them, and the next step is a decision, not a stage. Wiring
`plan-change` into a script that fed its output straight to `implement` would
make that choice for you and only tell you afterwards, which is the thing
`AGENTS.md` forbids.

Implementing is scriptable in principle, but only once a plan is pinned, and
pinning it is the decision above. Dispatch the `implement` agents yourself with
the `Agent` tool, one per unit, in a single message so they run concurrently.
If two of them could touch the same file, pass `isolation: "worktree"` so each
works on its own copy of the repo — the shared part is still one agent's job
first, but the isolation means a mistake about that costs a conflict you can
see rather than a file two agents interleaved.

A worktree isolates files and nothing else. A test runner claims what it needs
by fixed name — worker databases, a browser debugging port, a build directory —
so concurrent agents take the same things whatever their working directory:
tell each `implement` agent whether it is the only one running, and where it is
not, let it report the command and leave the tests to `verify` afterwards.
Dispatching one agent alone is the case where it can run its own.

## What the agents cannot see

A subagent gets `AGENTS.md`, because `CLAUDE.md` imports it — checked, not
assumed: a `scout` agent asked to quote `## Deployment state` and "committing
is the caller's decision" quoted both without opening a file. So do not restate
an `AGENTS.md` rule in an agent body. It is already there, and a second copy is
one more place to forget when the rule changes.

What a subagent does **not** get is `docs/`, which is read on demand rather
than pre-loaded. So every body is a pointer rather than a copy, because a model
given one will follow it: `review-design` is told to read the project's stated
conventions and judge the change against the whole of them, `implement` to read
the parts bearing on what it is writing and look for what differs between
development and production, `scout` to read the map `AGENTS.md` points it at.
None of them carries a command or a runner: those are the project's to state,
and `AGENTS.md` is what carries every pointer that reaches them.

`scout`'s pointer is why a project owes it a map doc of its own. It reads that
doc in full whenever a question turns on where something lives, which only
prices well while the doc is the map and nothing else — a thousand tokens, not
sixteen. Reaching the same fifty lines inside a general tooling doc costs the
whole file on every dispatch, and stating the map in the body instead costs it
whether the map is wanted or not, and leaves the one body in the roster that
would only ever work in one repository. The size is the load-bearing part, so a
map doc should say so in its own opening.

The rest of every body is the agent's own role, which exists nowhere else —
what it may not do, what counts as a finding, where it stops and hands back.
That part does not shrink with a stronger model: Opus knows how to review, and
what it needs from us is this project's bar, not the method.

It does not get this conversation either, and it does not get a skill unless
`Skill` is in its own `tools` list. `plan-change`, `implement` and
`review-design` have it, so they can read `testing`, `comments`,
`design-principles` and whatever scaffolding skill the project ships; `scout`
and `verify` do not, because neither judges anything.

So when a rule in `AGENTS.md` changes, the agent bodies need no edit, and when
a doc is renamed, only the `AGENTS.md` index it is reached through does — no
body names a file under `docs/` at all. Three things can still rot: a map doc
growing past the size that made `scout`'s read cheap, an `AGENTS.md` section
renamed under the bodies pointing at it, which `grep -rn '§' ~/.claude/agents/`
finds, and a project whose stated facts stop matching its own tree.

## What comes back is yours to act on

An agent's report goes to you, not to the caller. Relay what matters — a
findings table, a plan's alternatives, a test failure with its output — rather
than the transcript.

Nothing in the roster commits, and nothing in it applies a refactor. Both are
the caller's decision, so a finished fan-out ends with you saying what is
uncommitted and what was proposed but not done.
