// The skill states the workflow's cap, its dimension count and a whole cost
// table in prose. Every one of those is a number copied out of the script, and
// a copied number goes stale in silence — the run still works, the doc just
// stops describing it. These are what make it stop being silent: change
// MAX_VERIFY_TOTAL, add a dimension, or widen an enum, and the suite fails
// until the prose is redrawn.
//
// The concurrency cap is deliberately not here. It is the runtime's, on a
// machine that varies, so there is nothing in this repository to hold it to —
// which is exactly why the skill declines to state it and does state these.
//
// Run: node --test 'test/*.test.mjs'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'

const read = (rel) => readFileSync(fileURLToPath(new URL(rel, import.meta.url)), 'utf8')
const SCRIPT = read('../workflows/review-change.js')
const SKILL = read('../skills/fan-out/SKILL.md')

// The skill wraps at eighty columns, so a phrase it states is rarely on one
// line. Everything below matches against the collapsed form.
const FLAT = SKILL.replace(/\s+/g, ' ')

const capture = (re, what) => {
  const m = SCRIPT.match(re)
  assert.ok(m, `the script no longer contains ${what} — this test is reading the wrong thing`)
  return m[1]
}

const CAP = Number(capture(/const MAX_VERIFY_TOTAL = (\d+)/, 'MAX_VERIFY_TOTAL'))
const DEEP_VOTES = Number(capture(/DEPTH === 'deep' \? (\d+) : 1/, 'the deep vote count'))
const DIMENSIONS = capture(/const PER_UNIT = \[([^\]]*)\]/, 'PER_UNIT').match(/key:/g).length
const WHOLE = capture(/const WHOLE_CHANGE = \{ key: '([a-z]+)'/, 'WHOLE_CHANGE')
const FIXED = 2 // the scout and the checks agent, whatever the change is

const enumAfter = (first) => capture(new RegExp(`enum: \\[('${first}'[^\\]]*)\\]`), `the enum starting '${first}'`).split(',').length

const WORDS = { 1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five', 6: 'six', 7: 'seven', 20: 'twenty', 60: 'sixty' }
const word = (n) => {
  assert.ok(WORDS[n], `no word form for ${n}, and the skill spells this one out — add it here and redraw the prose`)
  return WORDS[n]
}

const states = (phrase) => assert.ok(FLAT.includes(phrase), `the skill no longer says "${phrase}"`)

test('the verification cap in prose is the cap in the script', () => {
  states(`${word(CAP)} most severe candidates are verified`)
  states(`at most ${CAP} at \`normal\`, ${CAP * DEEP_VOTES} at \`deep\``)
  states(`up to ${word(CAP * DEEP_VOTES)} of them`)
})

test('the review formula is the dimension count', () => {
  states(`\`${DIMENSIONS}n + 1\``)
  states(`${word(DIMENSIONS)} dimensions per unit`)
  states(`**fixed** — ${word(FIXED)}, the scout and the checks agent`)
})

test('every cell of the cost table reconciles', () => {
  // n units buy three dimensions each plus conventions once; a change with no
  // code in it buys conventions alone.
  const reviews = (n) => (n === 0 ? 1 : DIMENSIONS * n + 1)
  const rows = [
    ['none (no code changed)', 0],
    ['1, or a tree with no unit division', 1],
    ['2', 2],
    ['4', 4],
  ]

  for (const [label, n] of rows) {
    const normal = reviews(n) + FIXED + CAP
    const deep = reviews(n) + FIXED + CAP * DEEP_VOTES
    assert.ok(FLAT.includes(`| ${label} | ≤ ${normal} | ≤ ${deep} |`), `the row for ${label} should read ≤ ${normal} / ≤ ${deep}`)
  }
})

test('the dimension names in prose are the dimensions dispatched', () => {
  for (const [, key] of capture(/const PER_UNIT = \[([^\]]*)\]/, 'PER_UNIT').matchAll(/key: '([a-z]+)'/g)) {
    states(`\`${key}\``)
  }
  states(`\`${WHOLE}\``)
})

test('the enum sizes in prose are the enum sizes in the schemas', () => {
  states(`names one of ${word(enumAfter('passed'))} outcomes`)
  states(`one of ${word(enumAfter('crosses'))} states`)
})

test('the friction fields in prose are the fields on the schema', () => {
  const fields = capture(/required: \['about'([^\]]*)\]/, "the friction item's required list")
  for (const f of `'about'${fields}`.match(/'([a-zA-Z]+)'/g).map((q) => q.slice(1, -1))) states(`\`${f}\``)
  states('`sources`') // added by the collector, not by the agent
})

test('the fact table has as many rows as the skill says facts', () => {
  const section = SKILL.split('## What the project has to state')[1].split('\n## ')[0]
  const lines = section.split('\n')
  // Everything after the header and its separator, up to the blank line that
  // ends the table — the header is not a fact and neither is the rule under it.
  const start = lines.findIndex((l) => /^\|\s*-/.test(l)) + 1
  assert.ok(start > 0, 'no fact table found in the skill')
  const rows = lines.slice(start).filter((l) => l.startsWith('|'))
  const spelt = word(rows.length)
  states(`${spelt[0].toUpperCase()}${spelt.slice(1)} facts, stated once in the map doc`)
})
