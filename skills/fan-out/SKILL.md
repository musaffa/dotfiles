---
name: fan-out
description: Use when a change is big enough to want more than one agent on it — reviewing a diff across the units it touches, planning something structural, or implementing a chosen plan unit by unit. Covers which agent does which job, which model each runs on, what the project has to state for any of it to work, and how to dispatch them. Read it before starting the work, because whether to fan out is decided before the first file is opened, not partway through.
---

# Fanning out across agents

The roster is `~/.claude/agents/`, one file per agent, with one workflow beside
it in `~/.claude/workflows/`. Both are shared by every project on this machine
and state no fact about any of them.

**Reading this skill is not authorisation to spawn a fan-out.** The caller
asking for one — by name, by asking for a review, or by asking for a workflow —
is. Where you reached this skill yourself because the work looked like it
wanted more than one agent, say what the run would cost, in agents, off the
table below, and wait. A fan-out is the most expensive thing here and the
caller is the one paying for it.

## The roster

Each agent's model, effort and tool access live in its own frontmatter, which
is authoritative. **Never pass `model:` at a call site** — not to `Agent`, not
to `agent()` in a script — a model named in two places disagrees with itself
later. The table is documentation and goes stale; the frontmatter is what runs.

| Agent | Model | For |
|---|---|---|
| `plan-change` | Opus | Reads the docs and the code, dispatching `scout` for the paths, then returns a plan naming the alternatives and recommending one. Never edits |
| `implement` | Sonnet | Writes one already-decided change in one unit. Never commits, never widens, never restructures anything the plan did not pin |
| `review-design` | Opus | Reviews one dimension of one unit. Reads only; never edits, never runs tests |
| `refute` | Sonnet | Takes one finding a reviewer raised and tries to break it. Reads only; the verdict is the whole of its answer |
| `scout` | Haiku | Locates things. Which units a diff touches, where a symbol lives, which test directories cover a file |
| `verify` | Haiku | Runs the linter and the tests, reports what failed. Fixes nothing |

## What the project has to state

Seven facts, stated once in the map doc `AGENTS.md` § Documentation indexes.
Keep them a table of short rows — `scout` reads that doc in full on every
dispatch, and its size is what keeps the read cheap.

| Fact | What asks for it |
|---|---|
| The unit the tree divides into, and where those units live | The division of labour below. A tree that divides into none says so |
| Where a unit's tests sit | `scout` |
| Which file kinds the project counts as code | The review workflow |
| The command that reports style without rewriting it | `verify`, and `implement`, which lints what it wrote. The mode matters: a fix the linter applies is an edit neither may make |
| The runner a suite-width scope takes | `verify`, and the workflow, which pairs each scope with a runner by its width |
| The runner a narrower scope takes | The same pairing, at the other width |
| The whole command that runs every test there is | `verify`, where the change reaches past the files it edits |

State every row. A missing one is guessed at by a Haiku agent at `effort: low`,
and the guess comes back looking like an answer.

## When it is worth it

**Reviewing a written change** — the workflow below.

**Planning something structural** — one `plan-change` agent: a refactor, a
schema change, a new part of the tree, anything crossing a unit boundary. One
agent, not several: three plans is something you then have to referee.

**Implementing a chosen plan that spans units** — one `implement` agent per
unit, dispatched together, once the plan is pinned. They must not touch the
same files or they collide in one; where the plan has them sharing one, that
part is one agent's job first and the rest wait. How to dispatch them is below.

**Not worth it** for a change small enough to hold in one read, a question
about how something works, or anything where dispatching costs more than
opening the file would. `scout` and `verify` are cheap enough to call
speculatively; the Opus agents are not.

Where the tree divides into no unit, divide by dimension instead: four agents
over the whole change rather than four per unit.

## The review workflow

```
Workflow({ scriptPath: '~/.claude/workflows/review-change.js', args: { repo: '/path/to/repo' } })
Workflow({ scriptPath: '~/.claude/workflows/review-change.js', args: { repo: '…', depth: 'deep' } })
Workflow({ scriptPath: '~/.claude/workflows/review-change.js', args: { repo: '…', target: 'master..HEAD' } })
```

- **Pass `repo` whenever more than one repository is in reach.** A dispatched
  agent resolves its own root; unnamed, the run lints and tests the wrong
  project and reports it clean. Leave it out only in a single-repository
  session
- **Pass the path, not `{ name: 'review-change' }`** — the name registry holds
  only the built-in workflows. Expand `~` yourself
- **Invoke it through `Workflow`, never by a name.** A skill or a slash command
  passes its arguments as one string, so `repo`, `target` and `depth` all read
  `undefined`. The script stops where arguments were typed, not where none were
- The resolved path must sit inside `~/.claude` or under a
  `permissions.additionalDirectories` entry. Where `~/.claude/workflows` is a
  symlink, add the directory it points at. That entry takes `~`, not `$HOME`,
which stays a literal and grants nothing with no error to read

Defaults to the uncommitted working tree. `depth: 'deep'` raises the refuting
votes per finding from one to three; any other value is a `normal` run and says
so as it starts.

It runs `scout` once to read the project's facts and scope the diff, then
reviews: `correctness`, `tests` and `design` once per unit touched, and
`conventions` once over the whole change. Where no code changed, only
`conventions` runs and the checks agent runs the linter alone, with
`testsResult` reporting `not-run` — unless the scout named a test scope, which
still runs. A change with no code in it never escalates, whatever its
`boundaryReach`: that would buy the widest test run there is for the cheapest
change there is.

Reviews finish before verification starts. Findings are deduped across
dimensions first — one defect two reviewers found under different names costs
one refutation, not two — and the twenty most severe candidates are verified.
`verify` runs alongside the review rather than gating it. Test scopes come back
as targets and widths; the script pairs each with the runner the project named
for that width.

What comes back is deduped and severity-ordered, with `alsoFlaggedBy` naming
the other dimensions that found the same thing. There is no summarising agent;
the prose is yours to write.

### What it costs

For a change touching `n` units:

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

The rows count agents rather than what they cost, and the two no longer
track each other. Most of every row is verifiers, and a verifier is a
Sonnet agent answering one narrow question about one finding; the Opus in a
review run is the `3n + 1` reviews.

Ceilings, not costs, and they do not run at once: the runtime caps concurrency
against the cores of the machine the run is on. Read the formula off the
`Workflow` tool description.

A finding is dropped when **more** than half its verifiers refuted it, so a tie
leaves it standing. At `normal` one verifier decides either way; at `deep` one
refuter out of three leaves the finding standing, and so does one out of two
where a verifier died. Each survivor carries its vote count and its refuter
count.

The three at `deep` are not the same question asked three times. Each is given
one lens — whether the failure can be constructed at all, whether something
upstream already guards it, whether the finding is resting on a misreading of
the line — and refutes on that alone, so the extra two votes buy coverage
rather than agreement. The one verifier at `normal` is given all three, having
no second reading to fall back on. The lens is in the label.

A dead run is resumable. The tool result carries a `runId`; relaunch with
`Workflow({ scriptPath, args, resumeFromRunId })`. This session only, the args
must match, and a run still going must be stopped first. A `deep` run cut off
in the refute stage then costs its tail rather than its whole self.

It logs, as they happen, the things that make a quiet return misleading: a
review agent that died, so a dimension went unread rather than finding nothing;
a candidate whose verifiers all died, so it is neither confirmed nor refuted;
every finding cut at the cap, by `file:line`; and the linter and test result the
moment the checks agent lands, which is usually well before the refuters finish.

The first three are on the return as well, as `unreviewed`, `unjudged` and
`overCap`, beside `repoNamed`. Read them before you read `findings`: an empty
`findings` means one thing where those are empty too and another where four
reviewers died, and a log line is not something the caller's return carries.
Every exit returns all four, including the ones that stop before dispatching
anything — those carry `stopped` saying which.

Two things it will not tell you unless you look:

- `boundaryReach` is one of three states, decided by a Haiku agent at `effort:
  low`. On a change with code in it, `crosses` and `unknown` both run every
  test there is, so a guess never lands on the narrow scope; `boundaryReason`
  says what decided it
- `testsResult` names one of five outcomes rather than clean or not, and
  `testCount` is what separates a run that matched nothing from one that passed
  — the log line gives both, the rest of the checks are on the return

## Dispatching plan and implement yourself

There is no workflow for either. Both need a decision from you in the middle,
and a script cannot put you there.

Dispatch the `implement` agents with the `Agent` tool, one per unit, in a
single message so they run concurrently. Where two could touch the same file,
pass `isolation: "worktree"`.

```
Agent({
  subagent_type: 'implement',
  description: 'Implement <unit>',
  prompt: `<the pinned plan, pasted in full — its steps, the shapes it chose,
and what it deliberately left alone>

Your part is <unit>, at <path>. Do the steps under it and nothing outside it;
<other unit> is another agent's, running now.

Work in the repository at <absolute path>.

You are one of <n> agents running concurrently: do not run the tests. Name the
command you would have run and leave the suite to `verify`.`,
})
```

- **Paste the plan, do not summarise it.** The agent cannot see the
  conversation it was decided in, and a prompt that refers to the plan hands it
  a decision to reconstruct, which its body forbids
- **Name the repository** whenever more than one is in reach — the same silent
  failure as `repo` above
- **Say whether the agent is alone.** A worktree isolates files and nothing
  else: a test runner claims worker databases, ports and build directories by
  fixed name. Dispatching one agent alone inverts the last line of the template
  — tell it so, and it runs its own tests

## What the agents cannot see

A subagent gets `AGENTS.md`, because `CLAUDE.md` imports it. Do not restate an
`AGENTS.md` rule in an agent body: a second copy is one more place to forget
when the rule changes. The same holds one layer down — a dispatched agent gets
its own body and its own schema descriptions, so a prompt that says either
again is a third copy, paid on every dispatch. A prompt says only what the
caller knows and the agent cannot.

It does not get `docs/`, this conversation, or any skill unless `Skill` is in
its own `tools` list. `plan-change`, `implement` and `review-design` have it,
for `testing`, `comments`, `design-principles` and any scaffolding skill the
project ships; `scout` and `verify` do not.

So every body is a pointer rather than a copy. No body names a file under
`docs/`, which would only ever work in one repository; each reaches one by a
handle resolved out of the `AGENTS.md` § Documentation entry it is sent to, so
the handle has to be a word that entry uses. `test/roster-pointers.test.mjs`
holds every pointer the roster depends on, to the shape it depends on.

## What the run tells you about itself

Every body in the roster ends by reporting **friction**: what got in the way of
answering, and what would remove it. The workflow carries a `friction` field on
the scope, review and checks schemas and returns them collapsed under
`friction`, each entry naming what it is `about`, `where`, the `note` itself,
whether it `affectedAnswer`, and the `sources` that raised it. `where`
identifies a duplicate the way `file:line` identifies a finding. The refuters
carry no such field; there can be up to sixty of them.

- **A note that made an answer worse is said when it arrives.** The workflow
  logs those as they come back rather than holding them for the return — it is
  the reason to distrust the run before you act on it. Do the same yourself;
  everything else waits
- **The rest go at the end of the session, in one block** — deduped against
  each other and against what you hit yourself. Yours belongs in it: a prompt
  you had to send twice, a phase that idled behind a barrier, an agent whose
  answer you threw away
- **It proposes; it never applies.** A note about a doc is a change to a doc
  and a note about the roster is a change to the roster. Both are the caller's,
  and the roster is shared — the next project inherits your fix unasked
- **A note names a file and what would change in it.** Anything else is a
  complaint
- A session with nothing to report says nothing. An empty block every time is
  how the block stops being read

## What comes back is yours to act on

An agent's report goes to you, not to the caller. Relay what matters — a
findings table, a plan's alternatives, a test failure with its output — rather
than the transcript.

Nothing in the roster commits, and nothing in it applies a refactor — both are
the caller's decision. A finished fan-out ends with you saying what is
uncommitted, what was proposed but not done, and what the run said about
itself.
