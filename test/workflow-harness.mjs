// Runs a workflow script the way the runtime does — as an async function body
// with the hooks injected as arguments — so its control flow can be exercised
// against canned agent replies instead of real ones.
//
// The script is not importable: it has a top-level `return`, a top-level
// `await`, and it reads `agent`, `log` and the rest off globals it never
// declares. Constructing the function is what makes all three legal at once,
// and it is the only way to test the branching without spending a fan-out.
//
// Run: node --test 'test/*.test.mjs'
import { readFile } from 'node:fs/promises'

const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor
const HOOKS = ['args', 'agent', 'parallel', 'pipeline', 'phase', 'log', 'workflow', 'budget']

export async function runWorkflow(path, { args, respond }) {
  // `export` is a module-only form and the body is not a module. The runtime
  // reads `meta` out separately; here it only has to parse.
  const source = (await readFile(path, 'utf8')).replace(/^export const meta = \{/m, 'const meta = {')

  const logs = []
  const calls = []
  const phases = []

  const agent = async (prompt, opts = {}) => {
    const call = {
      prompt,
      opts,
      label: opts.label ?? null,
      phase: opts.phase ?? null,
      agentType: opts.agentType ?? null,
      index: calls.length,
    }
    calls.push(call)
    return respond(call)
  }

  // The real one resolves a thrown thunk to null rather than rejecting, which
  // is what keeps one dead agent from discarding the whole stage. A stub that
  // rejected instead would pass tests the runtime would fail.
  const parallel = async (thunks) =>
    Promise.all(
      thunks.map(async (t) => {
        try {
          return await t()
        } catch {
          return null
        }
      }),
    )

  const notStubbed = (name) => async () => {
    throw new Error(`${name}() is not stubbed — the script under test did not use it before`)
  }

  const fn = new AsyncFunction(...HOOKS, source)
  const result = await fn(
    args,
    agent,
    parallel,
    notStubbed('pipeline'),
    (t) => phases.push(t),
    (m) => logs.push(String(m)),
    notStubbed('workflow'),
    { total: null, spent: () => 0, remaining: () => Infinity },
  )

  return { result, logs, calls, phases }
}

// Routes a reply by the phase the call was tagged with. A value is returned as
// is; a function is called with the call, so a test can vary the reply by
// label, prompt or index.
export function byPhase(map) {
  return (call) => {
    if (!(call.phase in map)) throw new Error(`no stub for phase ${call.phase} (label ${call.label})`)
    const reply = map[call.phase]
    return typeof reply === 'function' ? reply(call) : reply
  }
}

export const logged = (logs, re) => logs.some((l) => re.test(l))
export const promptFor = (calls, phase) => calls.find((c) => c.phase === phase)?.prompt ?? ''
export const labelsIn = (calls, phase) => calls.filter((c) => c.phase === phase).map((c) => c.label)
