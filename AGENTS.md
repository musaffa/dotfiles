# AGENTS.md

Primary instructions for **all** AI agents working on this project. These
override an agent's own defaults.

## Commits

- **Committing is the caller's decision.** Finish the change, say what is left
  uncommitted, and stop. A change being coherent and complete is not a reason
  to commit it — being asked is
- **"Commit this" means commit.** Do not run the specs first — whether to
  verify is the caller's decision, not a gate. Where verification matters and
  has not happened, say so alongside the commit
- **No AI attribution trailer**, whoever or whatever wrote the change. The
  commit's author is the person who made it
- **Run `stylua vim/` before committing a change under `vim/`** and fix what
  it reports. Formatting is not verification of behaviour; it is the shape the
  committed code has to be in

Those four decide whether a commit happens at all and what it may not carry, so
they are stated here where they load before the work does. What the message
itself says — subject line, whether the change needs a body, what belongs in one
— is the `commit-message` skill, read while drafting the message. An agent with
no skill of that name available should ask for the conventions rather than fall
back on its own defaults.

## Refactors

**Share the plan before making the change.** A refactor moves code that already
works, so the caller is the one who decides whether the new shape is worth
having. Say what you intend to change, which files it touches, and what you are
deliberately leaving alone — then wait. This holds however small or obvious the
change looks: a refactor already applied is harder to argue with than one still
being proposed. Renaming, moving, extracting, and collapsing all count, and so
does a cleanup noticed on the way to something else.

Look for the alternatives before settling on one — the first shape that works
is rarely the best one available. Where more than one would do, the plan names
them, says which you recommend and what makes it better, and then asks which to
take. A plan offering a single option has made the caller's decision and only
told them about it.

What makes one shape better than another — what an extraction is allowed to
hide, why a shorter result is not itself an argument — is the
`design-principles` skill, read while judging the alternatives rather than
after choosing one.
