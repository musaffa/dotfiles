// What is under test is the script's control flow, not its prose: which agents
// it dispatches, what it tells them, which findings survive, and what it
// returns. Every fixture below is deliberately domain-free — the script names
// no language and no framework, so neither does its suite.
//
// Run: node --test 'test/*.test.mjs'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { fileURLToPath } from 'node:url'

import { runWorkflow, byPhase, logged, promptFor, labelsIn } from './workflow-harness.mjs'

const SCRIPT = fileURLToPath(new URL('../workflows/review-change.js', import.meta.url))

const RUNNERS = { suite: 'test-suite', scoped: 'test-one', everything: 'test-all' }

const scopeOf = (over = {}) => ({
  unitWord: 'part',
  units: ['alpha'],
  files: ['alpha/thing'],
  codeFilesChanged: true,
  codeKinds: ['.rb', 'Rakefile'],
  linter: 'lint --check',
  runners: RUNNERS,
  testScopes: [{ target: 'tests/alpha', width: 'suite' }],
  boundaryReach: 'contained',
  boundaryReason: 'touches nothing shared',
  friction: [],
  ...over,
})

const CHECKS_OK = {
  linterClean: true,
  linterCommand: 'lint --check',
  linterOffenses: [],
  testCommand: 'test-suite tests/alpha',
  testsResult: 'passed',
  testCount: 12,
  testFailures: [],
  notCovered: 'nothing',
  scopeCorrected: 'none',
  friction: [],
}

const finding = (over = {}) => ({
  file: 'alpha/thing',
  line: 10,
  summary: 'the deadline is discarded',
  failure: 'a caller passing a deadline gets none applied',
  severity: 'high',
  ...over,
})

const noFindings = { findings: [], friction: [] }
const holds = { refuted: false, certain: true, reason: 'holds' }
const breaks = { refuted: true, certain: true, reason: 'guarded above' }

const run = (opts) => runWorkflow(SCRIPT, opts)

const stub = ({ scope, checks = CHECKS_OK, review = noFindings, refute = holds }) =>
  byPhase({ Scope: scope, Checks: checks, Review: review, Refute: refute })

test('a typed string bails before dispatching anything', async () => {
  const { result, calls, logs } = await run({ args: 'deep', respond: () => assert.fail('no agent should run') })

  assert.equal(result.stopped, 'args-not-an-object')
  assert.deepEqual(result.findings, [])
  assert.deepEqual(result.friction, [])
  assert.equal(calls.length, 0)
  assert.ok(logged(logs, /Ignoring "deep"/))
})

test('no args at all is a default run, not a bail', async () => {
  const { result } = await run({ args: undefined, respond: stub({ scope: scopeOf() }) })

  assert.equal(result.stopped, undefined)
  assert.ok(result.scope)
})

test('an unnamed repo is warned about; a named one reaches every prompt', async () => {
  const bare = await run({ args: {}, respond: stub({ scope: scopeOf({ testScopes: [] }) }) })
  assert.ok(logged(bare.logs, /No `repo` named/))
  assert.ok(!promptFor(bare.calls, 'Scope').includes('Work in the repository at'))

  const named = await run({ args: { repo: '/w/one' }, respond: stub({ scope: scopeOf(), review: { findings: [finding()], friction: [] } }) })
  assert.ok(!logged(named.logs, /No `repo` named/))
  for (const phase of ['Scope', 'Checks', 'Review', 'Refute']) {
    assert.ok(promptFor(named.calls, phase).includes('Work in the repository at `/w/one`'), `${phase} prompt names the repo`)
  }
})

test('nothing changed exits early but keeps what the scout said on the way', async () => {
  const note = { about: 'project-facts', where: 'docs/layout.md § roster', note: 'no linter row', affectedAnswer: true }
  const { result, calls, logs } = await run({
    args: {},
    respond: stub({ scope: scopeOf({ files: [], friction: [note] }) }),
  })

  assert.equal(calls.length, 1, 'only the scout ran')
  assert.ok(logged(logs, /Nothing changed/))
  assert.equal(result.friction.length, 1)
  assert.deepEqual(result.friction[0].sources, ['scope'])
  assert.ok(logged(logs, /Friction \(project-facts\) at docs\/layout\.md § roster, from scope: no linter row/))
})

test('a change with no code in it reviews conventions alone and runs no tests', async () => {
  const { calls, logs } = await run({
    args: {},
    // `unknown` reach would escalate a code change to the whole suite. With no
    // code in the change it must buy nothing at all.
    respond: stub({ scope: scopeOf({ codeFilesChanged: false, testScopes: [], boundaryReach: 'unknown' }) }),
  })

  assert.deepEqual(labelsIn(calls, 'Review'), ['review:all/conventions'])
  assert.ok(logged(logs, /No code changed/))
  assert.ok(logged(logs, /the checks agent runs the linter alone/))
  assert.ok(!logged(logs, /full suite is the honest scope/))

  const checks = promptFor(calls, 'Checks')
  assert.ok(checks.includes('lint --check'))
  assert.ok(checks.includes('Then stop there.'))
  assert.ok(checks.includes('`not-run`'))
  assert.ok(!checks.includes('test-all'))
})

test('a change with no code in it still runs a test scope the scout named', async () => {
  const { calls, logs } = await run({
    args: {},
    // Skipping the run is a fact about the diff AND about what the scout asked
    // for. Where it named a scope anyway, that is a better reason to run than
    // the file extensions are to skip.
    respond: stub({ scope: scopeOf({ codeFilesChanged: false, testScopes: [{ target: 'tests/docs', width: 'scoped' }] }) }),
  })

  assert.deepEqual(labelsIn(calls, 'Review'), ['review:all/conventions'])
  assert.ok(!logged(logs, /the checks agent runs the linter alone/))

  const checks = promptFor(calls, 'Checks')
  assert.ok(checks.includes('test-one tests/docs'))
  assert.ok(!checks.includes('Then stop there.'))
  assert.ok(!checks.includes('test-all'), 'no escalation without code, whatever the reach')
})

test('an unknown boundary escalates a code change to every test there is', async () => {
  const { calls, logs } = await run({ args: {}, respond: stub({ scope: scopeOf({ boundaryReach: 'unknown', boundaryReason: 'could not tell' }) }) })

  assert.ok(logged(logs, /Boundary reach unknown — the full suite is the honest scope\. could not tell/))
  assert.ok(promptFor(calls, 'Checks').includes('test-all'))
})

test('a contained change runs the scope it implies, paired with the runner for that width', async () => {
  const { calls, logs } = await run({
    args: {},
    respond: stub({ scope: scopeOf({ testScopes: [{ target: 'tests/alpha/one', width: 'scoped' }] }) }),
  })

  const checks = promptFor(calls, 'Checks')
  assert.ok(checks.includes('test-one tests/alpha/one'))
  assert.ok(!checks.includes('test-all'))
  assert.ok(!logged(logs, /honest scope/))
})

test('a tree that divides into no unit still divides by dimension', async () => {
  const { calls } = await run({ args: {}, respond: stub({ scope: scopeOf({ unitWord: '', units: [] }) }) })

  assert.deepEqual(labelsIn(calls, 'Review').sort(), [
    'review:all/conventions',
    'review:all/correctness',
    'review:all/design',
    'review:all/tests',
  ])
})

test('one defect found under two dimensions costs one refutation', async () => {
  const { result, calls, logs } = await run({
    args: {},
    respond: stub({
      scope: scopeOf(),
      review: (call) =>
        call.label === 'review:alpha/correctness'
          ? { findings: [finding({ summary: 'the deadline is discarded' })], friction: [] }
          : call.label === 'review:alpha/tests'
            ? { findings: [finding({ summary: 'discarded deadline is untested' })], friction: [] }
            : noFindings,
    }),
  })

  assert.equal(result.reported, 2)
  assert.equal(calls.filter((c) => c.phase === 'Refute').length, 1)
  assert.equal(result.findings.length, 1)
  assert.deepEqual(result.findings[0].alsoFlaggedBy, ['tests'])
  assert.ok(logged(logs, /2 finding\(s\) reported, 1 after collapsing duplicates/))
})

test('past the cap the excess is named rather than silently dropped', async () => {
  const many = Array.from({ length: 25 }, (unused, i) => finding({ line: i + 1, summary: `defect number ${i + 1} in the handler` }))
  const { result, calls, logs } = await run({
    args: {},
    respond: stub({ scope: scopeOf(), review: (c) => (c.label === 'review:alpha/correctness' ? { findings: many, friction: [] } : noFindings) }),
  })

  assert.equal(calls.filter((c) => c.phase === 'Refute').length, 20)
  assert.equal(result.attempted, 20)
  assert.ok(logged(logs, /5 left unverified and excluded: alpha\/thing:21/))
})

test('a single refuter is decisive at normal depth', async () => {
  const one = { args: {}, respond: stub({ scope: scopeOf(), review: { findings: [finding()], friction: [] }, refute: breaks }) }
  assert.equal((await run(one)).result.findings.length, 0)

  const two = { args: {}, respond: stub({ scope: scopeOf(), review: { findings: [finding()], friction: [] }, refute: holds }) }
  assert.equal((await run(two)).result.findings.length, 1)
})

// The order the three lenses are dispatched in, which is the order the labels
// come back in. A test that refutes "the first n" needs one.
const LENSES = ['reproduce', 'guard', 'misreading']

test('deep needs more than half the votes to drop a finding', async () => {
  const withRefuters = async (n) => {
    const { result, calls } = await run({
      args: { depth: 'deep' },
      respond: stub({
        scope: scopeOf(),
        review: { findings: [finding()], friction: [] },
        refute: (c) => (LENSES.indexOf(c.label.split('/').pop()) < n ? breaks : holds),
      }),
    })
    assert.equal(calls.filter((c) => c.phase === 'Refute').length, 3)
    return result.findings
  }

  const survived = await withRefuters(1)
  assert.equal(survived.length, 1, 'one refuter out of three leaves it standing')
  assert.equal(survived[0].refuters, 1)
  assert.equal(survived[0].votes, 3)

  assert.equal((await withRefuters(2)).length, 0, 'two out of three drops it')
})

test('the same gap reported by three agents is one suggestion with three sources', async () => {
  const at = (where, note, affectedAnswer = false) => ({ about: 'project-facts', where, note, affectedAnswer })
  const { result } = await run({
    args: {},
    respond: stub({
      scope: scopeOf({ friction: [at('docs/layout.md § roster', 'no row naming the linter')] }),
      review: (c) => (c.label === 'review:all/conventions' ? { findings: [], friction: [at('docs/layout.md § roster', 'the linter is not stated anywhere')] } : noFindings),
      checks: { ...CHECKS_OK, friction: [at('docs/layout.md § roster', 'had to guess the lint command')] },
    }),
  })

  assert.equal(result.friction.length, 1)
  // Arrival order, not dispatch order: the checks agent is fired before the
  // reviewers and files its note the moment it lands, so it is second here even
  // though it is awaited last.
  assert.deepEqual(result.friction[0].sources, ['scope', 'checks', 'review:all/conventions'])
})

test('two gaps in one doc stay two suggestions', async () => {
  const at = (where, note) => ({ about: 'project-facts', where, note, affectedAnswer: false })
  const { result } = await run({
    args: {},
    respond: stub({
      scope: scopeOf({
        friction: [at('docs/layout.md § roster', 'no row naming the linter'), at('docs/layout.md § tests', 'no row naming where tests sit')],
      }),
    }),
  })

  assert.equal(result.friction.length, 2)
})

test('an anchored note never merges with an unanchored one', async () => {
  const note = 'no row naming the linter'
  const { result } = await run({
    args: {},
    respond: stub({
      scope: scopeOf({
        friction: [
          { about: 'project-facts', where: 'docs/layout.md', note, affectedAnswer: false },
          { about: 'project-facts', where: '', note, affectedAnswer: false },
          { about: 'project-facts', where: '', note, affectedAnswer: false },
        ],
      }),
    }),
  })

  // The two unanchored ones collapse on wording; neither joins the anchored one.
  assert.equal(result.friction.length, 2)
  assert.deepEqual(
    result.friction.map((f) => f.where),
    ['docs/layout.md', ''],
  )
})

test('a note is said when it arrives only once it is one that cost the answer', async () => {
  const where = 'docs/layout.md § roster'
  const { result, logs } = await run({
    args: {},
    respond: stub({
      scope: scopeOf({ friction: [{ about: 'docs', where, note: 'stale row', affectedAnswer: false }] }),
      checks: { ...CHECKS_OK, friction: [{ about: 'docs', where, note: 'stale row', affectedAnswer: true }] },
    }),
  })

  assert.equal(result.friction.length, 1)
  assert.equal(result.friction[0].affectedAnswer, true)
  const said = logs.filter((l) => l.startsWith('Friction (docs)'))
  assert.equal(said.length, 1, 'said once, when it escalated — not again at the end')
  assert.ok(said[0].includes('from checks'))
  assert.ok(logged(logs, /1 note\(s\) about what got in the agents' way/))
})

test('a run nobody had trouble with says nothing about friction', async () => {
  const { result, logs } = await run({ args: {}, respond: stub({ scope: scopeOf() }) })

  assert.deepEqual(result.friction, [])
  assert.ok(!logged(logs, /[Ff]riction/))
})

test('an unrecognised depth says so rather than quietly running at one vote', async () => {
  const { calls, logs } = await run({ args: { depth: 'thorough' }, respond: stub({ scope: scopeOf(), review: { findings: [finding()], friction: [] } }) })

  assert.ok(logged(logs, /Unrecognised depth "thorough" — running at `normal`/))
  assert.equal(calls.filter((c) => c.phase === 'Refute').length, 1)

  const spelt = await run({ args: { depth: 'deep' }, respond: stub({ scope: scopeOf(), review: { findings: [finding()], friction: [] } }) })
  assert.ok(!logged(spelt.logs, /Unrecognised depth/))
})

test('a reviewer that returned nothing is named, not counted as clean', async () => {
  const { result, logs } = await run({
    args: {},
    respond: stub({ scope: scopeOf(), review: (c) => (c.label === 'review:alpha/tests' ? null : noFindings) }),
  })

  assert.ok(logged(logs, /1 of 4 review agent\(s\) returned nothing: review:alpha\/tests\. Unreviewed, not clean\./))
  assert.deepEqual(result.findings, [])
})

test('a candidate whose verifiers all died is neither confirmed nor dropped in silence', async () => {
  const { result, logs } = await run({
    args: {},
    respond: stub({ scope: scopeOf(), review: (c) => (c.label === 'review:alpha/correctness' ? { findings: [finding()], friction: [] } : noFindings), refute: null }),
  })

  assert.ok(logged(logs, /1 candidate\(s\) lost every verifier and are neither confirmed nor dropped: alpha\/thing:10/))
  assert.equal(result.attempted, 0)
  assert.deepEqual(result.findings, [])
})

test('the checks result is said when it lands, and its absence is said too', async () => {
  const failed = await run({
    args: {},
    respond: stub({ scope: scopeOf(), checks: { ...CHECKS_OK, linterClean: false, linterOffenses: ['a', 'b'], testsResult: 'failed', testCount: 12, scopeCorrected: 'was handed test-suite x, ran test-all' } }),
  })
  assert.ok(logged(failed.logs, /Checks: linter not clean, 2 offence\(s\); tests failed, 12 selected\. Scope corrected: was handed test-suite x, ran test-all/))

  const clean = await run({ args: {}, respond: stub({ scope: scopeOf() }) })
  assert.ok(logged(clean.logs, /Checks: linter clean; tests passed, 12 selected\.$/))

  const dead = await run({
    args: {},
    respond: byPhase({ Scope: scopeOf(), Review: noFindings, Refute: holds, Checks: () => { throw new Error('died') } }),
  })
  assert.equal(dead.result.checks, null)
  assert.ok(logged(dead.logs, /The checks agent returned nothing .* not the same as clean/))
})

test('a contained code change with no scope named says the checks agent was left to find one', async () => {
  const { logs } = await run({ args: {}, respond: stub({ scope: scopeOf({ testScopes: [] }) }) })

  assert.ok(logged(logs, /Code changed, the reach is contained, and no test scope was named/))
  assert.ok(!logged(logs, /the checks agent runs the linter alone/))
})

test('every way the run can end returns the same shape', async () => {
  // The last four are the ones that make a shortfall legible. A caller reading
  // `findings: []` cannot otherwise tell a clean review from a run whose
  // reviewers all died, whose candidates were cut at the cap, or that was never
  // told which repository to read.
  const KEYS = ['findings', 'checks', 'scope', 'attempted', 'reported', 'friction', 'repoNamed', 'unreviewed', 'overCap', 'unjudged']
  const typed = await run({ args: 'deep', respond: () => assert.fail('no agent should run') })
  const bare = await run({ args: '', respond: () => assert.fail('no agent should run') })
  const dead = await run({ args: {}, respond: byPhase({ Scope: null }) })
  const empty = await run({ args: {}, respond: stub({ scope: scopeOf({ files: [] }) }) })
  const full = await run({ args: {}, respond: stub({ scope: scopeOf() }) })

  for (const [name, r] of [['typed string', typed], ['bare name', bare], ['dead scout', dead], ['nothing changed', empty], ['a full run', full]]) {
    for (const k of KEYS) assert.ok(k in r.result, `${name} is missing ${k}`)
  }
})

test('the bare skill name bails as loudly as a typed one', async () => {
  // The empty string is the likeliest arrival by name and was the one the guard
  // let through, because it had no option to quote back. It reaches every agent
  // as an unnamed `repo`, which is the wrong-repository failure.
  for (const bare of ['', '   ']) {
    const { result, calls, logs } = await run({ args: bare, respond: () => assert.fail('no agent should run') })

    assert.equal(result.stopped, 'args-not-an-object')
    assert.equal(calls.length, 0)
    assert.ok(logged(logs, /Reached by name with no options/))
  }
})

test('a scout that died is not reported as nothing having changed', async () => {
  const { result, calls, logs } = await run({ args: { repo: '/r' }, respond: byPhase({ Scope: null }) })

  assert.equal(result.stopped, 'scope-agent-returned-nothing')
  assert.equal(calls.length, 1, 'nothing was dispatched behind it')
  assert.ok(logged(logs, /The scope agent returned nothing/))
  assert.ok(!logged(logs, /Nothing changed/), 'the opposite fact')

  // The empty diff keeps the old wording, and keeps `stopped` off the return.
  const none = await run({ args: {}, respond: stub({ scope: scopeOf({ files: [] }) }) })
  assert.equal(none.result.stopped, undefined)
  assert.ok(logged(none.logs, /Nothing changed/))
})

test('an unnamed repo is a fact on the return, not only a log line', async () => {
  const bare = await run({ args: {}, respond: stub({ scope: scopeOf() }) })
  assert.equal(bare.result.repoNamed, false)

  const named = await run({ args: { repo: '/r' }, respond: stub({ scope: scopeOf() }) })
  assert.equal(named.result.repoNamed, true)
})

test('what a run did not cover comes back on the return, not only in the log', async () => {
  const many = Array.from({ length: 22 }, (unused, i) => finding({ line: i + 1, summary: `defect number ${i + 1} in the handler` }))
  const { result } = await run({
    args: { repo: '/r' },
    respond: byPhase({
      Scope: scopeOf(),
      Checks: CHECKS_OK,
      Review: (c) => (c.label === 'review:alpha/correctness' ? { findings: many, friction: [] } : c.label === 'review:alpha/tests' ? null : noFindings),
      // Every verifier dies, so nothing is confirmed and nothing is refuted.
      Refute: () => null,
    }),
  })

  assert.deepEqual(
    result.unreviewed.map((u) => u.label),
    ['review:alpha/tests'],
  )
  assert.equal(result.overCap.length, 2, '22 findings, 20 verified')
  assert.deepEqual(result.overCap.map((f) => f.line), [21, 22])
  assert.equal(result.unjudged.length, 20, 'every candidate lost every verifier')
  assert.deepEqual(result.findings, [], 'and none of it is a finding')
})

test('two defects on one line are not merged by a single shared noun', async () => {
  // `Math.min` normalisation scored these 0.5 — one word in common, out of the
  // shorter summary's two — and collapsed them into one candidate whose single
  // refuter answered one claim for both.
  const { result, calls } = await run({
    args: { repo: '/r' },
    respond: stub({
      scope: scopeOf(),
      review: (c) =>
        c.label === 'review:alpha/correctness'
          ? { findings: [finding({ summary: 'the repository leaks a connection' })], friction: [] }
          : c.label === 'review:alpha/design'
            ? { findings: [finding({ summary: 'N+1 query in repository' })], friction: [] }
            : noFindings,
    }),
  })

  assert.equal(result.reported, 2)
  assert.equal(calls.filter((c) => c.phase === 'Refute').length, 2, 'two defects, two refutations')
  assert.equal(result.findings.length, 2)
})

test('a merge that does happen shows the refuter every claim it swallowed', async () => {
  const { calls } = await run({
    args: { repo: '/r' },
    respond: stub({
      scope: scopeOf(),
      review: (c) =>
        c.label === 'review:alpha/correctness'
          ? { findings: [finding({ summary: 'the deadline is discarded', failure: 'the deadline never applies' })], friction: [] }
          : c.label === 'review:alpha/tests'
            ? { findings: [finding({ summary: 'discarded deadline is untested', failure: 'no spec covers it' })], friction: [] }
            : noFindings,
    }),
  })

  const refute = promptFor(calls, 'Refute')
  assert.ok(refute.includes('discarded deadline is untested'), 'the swallowed claim')
  assert.ok(refute.includes('no spec covers it'), 'and its failure')
  assert.ok(refute.includes('leave it standing where ANY of these claims survives'))
})

test('a code file in the diff outvotes a scout that called the change code-free', async () => {
  const { calls, logs } = await run({
    args: { repo: '/r' },
    respond: stub({ scope: scopeOf({ codeFilesChanged: false, files: ['docs/x.md', 'alpha/thing.rb'] }) }),
  })

  assert.ok(logged(logs, /came back false, but 1 changed file\(s\) match a kind this project counts as code: alpha\/thing\.rb/))
  assert.deepEqual(labelsIn(calls, 'Review').sort(), ['review:all/conventions', 'review:alpha/correctness', 'review:alpha/design', 'review:alpha/tests'])
})

test('a change with no code in it and no code file to find stays a conventions run', async () => {
  const { calls, logs } = await run({
    args: { repo: '/r' },
    respond: stub({ scope: scopeOf({ codeFilesChanged: false, files: ['docs/x.md', 'README.md'], testScopes: [] }) }),
  })

  assert.deepEqual(labelsIn(calls, 'Review'), ['review:all/conventions'])
  assert.ok(!logged(logs, /outvote|came back false, but/))
})

test('a project that named no linter is not reported clean', async () => {
  const { calls, logs } = await run({ args: { repo: '/r' }, respond: stub({ scope: scopeOf({ linter: '' }) }) })

  assert.ok(logged(logs, /named no linter command/))
  const checks = promptFor(calls, 'Checks')
  assert.ok(checks.includes('Do not report clean for a linter you did not run.'))
  assert.ok(!checks.includes('Run `` over the project'), 'an empty command is not a command')
})

test('a linter that never ran is logged as that, not as clean', async () => {
  const { logs } = await run({
    args: { repo: '/r' },
    respond: stub({ scope: scopeOf(), checks: { ...CHECKS_OK, linterClean: true, linterCommand: '' } }),
  })

  assert.ok(logged(logs, /no linter run, which is not the same as clean/))
})

test('a width the project named no runner for is named, not handed over as a bare path', async () => {
  const { calls } = await run({
    args: { repo: '/r' },
    respond: stub({ scope: scopeOf({ runners: { suite: '', scoped: 'test-one', everything: 'test-all' } }) }),
  })

  const checks = promptFor(calls, 'Checks')
  assert.ok(checks.includes('(this project named no `suite` runner) tests/alpha'))
})

test('the full suite replaces the narrow scopes rather than joining them', async () => {
  const { calls } = await run({ args: { repo: '/r' }, respond: stub({ scope: scopeOf({ boundaryReach: 'crosses' }) }) })

  const checks = promptFor(calls, 'Checks')
  assert.ok(checks.includes('test-all'))
  assert.ok(checks.includes('run it instead of them rather than as well'))
  assert.ok(!checks.includes('The scope this change implies, as read off the diff'), 'the additive wording is gone')
})

test('the three deep verifiers read the finding three different ways', async () => {
  const deep = await run({
    args: { depth: 'deep' },
    respond: stub({ scope: scopeOf(), review: (c) => (c.label === 'review:alpha/correctness' ? { findings: [finding()], friction: [] } : noFindings) }),
  })

  assert.deepEqual(labelsIn(deep.calls, 'Refute'), LENSES.map((l) => `refute:thing:10/${l}`))
  const asks = deep.calls.filter((c) => c.phase === 'Refute').map((c) => c.prompt)
  assert.equal(new Set(asks).size, 3, 'three identical prompts would be three votes on one reading')
  assert.ok(asks[0].includes('Construct the input'))
  assert.ok(asks[1].includes('Look up the call graph'))
  assert.ok(asks[2].includes('Read the code as written'))
  for (const a of asks) assert.ok(a.includes('Default to refuted=true'))

  // One verifier has no second reading to fall back on, so it gets all three.
  const normal = await run({
    args: {},
    respond: stub({ scope: scopeOf(), review: (c) => (c.label === 'review:alpha/correctness' ? { findings: [finding()], friction: [] } : noFindings) }),
  })
  assert.deepEqual(labelsIn(normal.calls, 'Refute'), ['refute:thing:10'])
  const only = promptFor(normal.calls, 'Refute')
  for (const phrase of ['Construct the input', 'Look up the call graph', 'Read the code as written']) assert.ok(only.includes(phrase), phrase)
  assert.ok(!only.includes('That is your lens'))
})

test('a dispatched agent is not told again what its own body already says', async () => {
  // The bodies carry the friction rules and the schema carries the field
  // descriptions. A third copy in the prompt is a third place to forget them,
  // and it is paid on every dispatch.
  const { calls } = await run({ args: {}, respond: stub({ scope: scopeOf() }) })
  const restated = [
    'dressed as friction', // review-design.md says this, and says it better
    'only agent here that runs anything', // verify.md
    'Nothing got in your way is the common answer', // all five bodies
    'Put the file and the section in where', // the schema's own `where` description
  ]

  for (const c of calls) {
    for (const phrase of restated) assert.ok(!c.prompt.includes(phrase), `${c.phase} prompt restates "${phrase}"`)
  }
})
