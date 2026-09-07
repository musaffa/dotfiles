// The rot vectors the skill used to list in prose. A list a human has to
// remember to re-read is not a check; these are.
//
// Two of them freeze a set rather than resolve it. This repository cannot see
// the projects the roster is pointed at, so it cannot confirm that a handle or
// a section name lands anywhere — what it can do is fail the moment a new one
// appears, which turns "add a pointer" into a deliberate act with a checklist
// attached instead of a silent one-word edit.
//
// Run: node --test 'test/*.test.mjs'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readdirSync, readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'

const DIR = fileURLToPath(new URL('../agents/', import.meta.url))
const BODIES = readdirSync(DIR)
  .filter((f) => f.endsWith('.md'))
  .map((f) => ({ name: f, flat: readFileSync(DIR + f, 'utf8').replace(/\s+/g, ' ') }))

const found = (re) => BODIES.flatMap(({ name, flat }) => [...flat.matchAll(re)].map((m) => `${name}: ${m[1] ?? m[0]}`))

test('the roster is where this test thinks it is', () => {
  // Without this, a glob that matched nothing would pass every check below.
  assert.ok(BODIES.length >= 5, `found ${BODIES.length} bodies in ${DIR}`)
})

test('no body names a file under docs/', () => {
  // A body that names a path only ever works in one repository, and a rename
  // breaks it leaving nothing behind to grep for.
  assert.deepEqual(found(/docs\/[A-Za-z0-9_.-]+/g), [])
})

test('exactly one body names a heading inside a project doc', () => {
  assert.deepEqual(found(/`##[^`]*`/g), ['review-design.md: `## Key Conventions`'])
})

test('every doc handle is one of the frozen set', () => {
  // A handle resolves out of the `AGENTS.md` § Documentation entry the body is
  // sent to, so a new one is only safe if every project's entry uses that word.
  const KNOWN = ['layout', 'map', 'tooling']
  const used = [...new Set(found(/([a-z]+) doc `AGENTS\.md`/g).map((h) => h.split(': ')[1]))].sort()
  assert.deepEqual(used, KNOWN, 'a handle changed — check every project’s § Documentation entry uses the new word')
})

test('every AGENTS.md section a body points at is one of the frozen set', () => {
  const KNOWN = ['Documentation', 'Refactors', 'Tests']
  const used = [...new Set(found(/§ ([A-Z][a-z]+)/g).map((s) => s.split(': ')[1]))].sort()
  assert.deepEqual(used, KNOWN, 'a section pointer changed — check every project’s AGENTS.md has that heading')
})

test('every body still ends by reporting friction', () => {
  for (const { name, flat } of BODIES) {
    assert.ok(flat.includes('## What got in your way'), `${name} has no friction section`)
  }
})
