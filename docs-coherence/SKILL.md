---
name: docs-coherence
description: Audit a repo's docs for contradictions, stale or wrong claims, and opinions stated as facts, against each other and against the code. Read-only report.
disable-model-invocation: true
argument-hint: "[docs path, default: docs/ + root *.md]"
---

Audit the repo's documentation as a set of **claims**: statements that something is true, decided, or built. Find every claim that conflicts with another claim, with the code, or with the environment. Change nothing; the output is a report.

## 1. Map the doc set

Collect the docs: the argument path if given, else `docs/**`, root `*.md` (`README`, `AGENTS`, `CLAUDE`, `GLOSSARY`, `CONTEXT`), and every `adr/` folder.

Establish the **authority order**: which doc wins when two disagree. Look for explicit statements first ("fait foi", "supersedes", "source of truth", `Status: accepted / superseded / proposal`). Then dates. Then ADRs over analyses, decisions over proposals.

Done when: every doc is listed with its status (decision, proposal, reference, analysis) and its rank in the authority order, and you can say which doc wins any pair.

## 2. Check references mechanically

Before any judgement, verify what a command can verify:

- every path, file, script, package or skill a doc names exists (`ls`, `grep`, `package.json`, config files);
- every relative Markdown link resolves;
- every version a doc pins matches the manifest or lock file, when code exists;
- every ADR another doc cites exists, and its status matches how it is cited.

Done when: every reference in the doc set has been checked, not sampled.

## 3. Extract and cross-check claims

For each doc, list its load-bearing claims: decisions, terms and their definitions, versions, behaviour of the system, status of work. With more than ~15 docs, dispatch one sub-agent per group of docs to extract claims, and do the cross-check yourself.

Cross-check each claim against:

- **other docs**: same topic, different answer; a term used with two meanings; a decision reversed without the old doc marked superseded;
- **the code**, when it exists: the doc says X is built or works a way, the code says otherwise;
- **itself**: a doc marked "proposal" that other docs treat as decided, or the reverse.

Done when: every claim from step 3 has been compared with every other doc touching its topic.

## 4. Classify

| Type | Meaning |
| --- | --- |
| **Contradiction** | Two docs give different answers to the same question. |
| **Wrong** | The code, a manifest or a command disproves the doc. |
| **Stale** | The doc was true once: superseded ADR not marked, renamed file, old version. |
| **Dangling** | The doc points at something that does not exist. |
| **Undecided-as-decided** | A proposal or open question stated as settled, or an opinion stated as a verified fact in a doc ranked as authoritative. |

Opinions inside a doc marked proposal or analysis are its job, not a finding.

Severity: **High** if an agent or developer following the doc would build the wrong thing. **Medium** if it would waste time. **Low** if it only misleads a reader.

Every finding carries evidence: both quotes with `file:line`, or one quote with the command and its output. A finding without evidence is dropped.

## 5. Report

Lead with the count per type and severity. Then one row per finding, highest severity first:

| # | Type | Sev | Where | Evidence | Which source wins | Fix |
| --- | --- | --- | --- | --- | --- | --- |

"Which source wins" comes from the authority order of step 1; write "unclear: ask" when the order does not settle it, and list those as questions for the user at the end.

Close with **gate candidates**: the findings a script could catch on every commit (dangling paths, version drift, ADR status), so the next drift fails CI instead of waiting for this audit.
