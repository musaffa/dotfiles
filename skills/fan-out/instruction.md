## Fanning out

**Whether to split work across several agents is decided before the work
starts.** An agent already reading files single-handed has made the decision by
omission.

Three rules bind whatever is dispatched. Two are the reasons `## Commits` and
`## Refactors` give above: **nothing dispatched may commit**, and **nothing
dispatched may decide a refactor** — it applies what the plan pinned, and
reports any other shape it would like rather than taking it.

The third is that **everything dispatched reports what got in its way** — a
fact it had to guess at because no doc states it, a doc that contradicts the
code, a run that cost far more than the answer was worth. It names the file and
what would change in it at the end of its report, and changes nothing itself.
Nothing got in the way is the common answer and takes one line; absent, it
reads as a run that did not look.

Which agent does which job and how the work is divided are the `fan-out` skill,
whose roster is `~/.claude/agents/`, one file per agent.
