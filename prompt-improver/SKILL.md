---
name: prompt-improver
description: Rewrite a user's draft prompt into a stronger, clearer prompt for an AI model using prompt-engineering best practices (natural phrasing, explicit context, response directives, output format stated last, interrogative framing, few-shot examples, chain-of-thought, negative prompting). Runs a short interview to pull out context specific to the user -- their audience, data, constraints, and the output they actually want -- then writes the improved prompt plus a 'what changed and why' explanation to a Markdown file. Use whenever the user wants to improve, refine, rewrite, strengthen, polish, or sanity-check a prompt they intend to send to an AI/LLM (ChatGPT, Claude, Gemini, etc.) -- e.g. 'make this prompt better', 'help me word this for ChatGPT', 'is this a good prompt?', 'how should I ask the AI to...', 'turn this into a prompt'. Trigger even if they never say 'prompt' but are clearly drafting instructions for a model. Do NOT use it for editing ordinary prose (emails, essays, docs) not meant to be fed to an AI.
---

# Prompt Improver

Turn a rough, underspecified prompt into one that reliably gets the user what they want from an AI model.

The value here is **not** reformatting words. Most weak prompts fail because they are missing information that lives only in the user's head — who the output is for, what data will be pasted in, what "good" looks like, what to leave out. A model rewriting in isolation can only polish grammar; it cannot supply that context. So this skill does two things a quick reword cannot:

1. **Interrogates the user** to surface the context that is specific to them, then
2. **Rewrites** the prompt applying proven prompt-engineering principles, and explains *what changed and why* so the user gets better at writing prompts themselves.

The output is a Markdown file containing the improved prompt (ready to copy) plus the reasoning behind each change.

## When this fires

The user has a prompt they're about to send to an AI and wants it to work better: "make this prompt better," "help me word this for ChatGPT," "is this a good prompt?," "how do I ask the model to…," "turn this idea into a prompt." They may paste a draft, or they may just describe what they're trying to get — both count. If they're editing prose that *isn't* destined for a model (an email, an essay), this skill does not apply.

## What you produce

One Markdown file (default: `./<short-kebab-title>-prompt.md` in the current directory — mention the path, only ask if context suggests elsewhere). Use this exact structure:

```
# <Short title> — Improved Prompt

## Improved prompt
<the polished prompt inside a fenced code block so it copy-pastes cleanly>

## What changed and why
- **<principle applied>:** <the specific change, and why it helps this task>
- ... (one bullet per meaningful change; tie each to a principle, not "made it clearer")

## Original draft
> <the user's original prompt, quoted — so they can see the before/after>
```

Keep the "what changed and why" honest and specific. "Added an output directive: '…in three sentences' so the model doesn't ramble" teaches something; "made it clearer" teaches nothing.

## Workflow

### 1. Capture the draft and the real goal

Get two things: the prompt the user has now (or the task they want a prompt for), and what a *great* answer from the AI would look like. Restate the goal in one sentence so a misread surfaces immediately. The goal is your success criterion — every later choice serves it.

### 2. Diagnose against the four elements of a prompt

Every strong prompt has four parts. Walk the draft against them — this is the fastest way to see what's missing:

| Element | Question | If missing… |
|---|---|---|
| **Instruction** | What exactly should the model *do*? Is it one clear task or a tangle? | Sharpen the verb; split if it's several tasks (see step 4). |
| **Context** | What does the model need to know to answer well — audience, purpose, domain, situation? | Often user-specific → **interview for it (step 3)**. |
| **Input data** | What will be fed in (article, data, code)? Is it real content or a placeholder? | Mark with a bracketed placeholder like `[insert article text]`, or get it from the user. |
| **Output indicator** | What form should the answer take — format, length, tone, what to include/exclude? | Add an explicit directive, placed at the **end** of the prompt. |

Whatever is missing and *inferable* you fill in yourself. Whatever is missing and *specific to the user* becomes an interview question.

### 3. Interview to fill what only the user knows

This is where the skill earns its keep. Ask the few sharp questions whose answers you genuinely cannot guess and that change the prompt. Don't interrogate for its own sake — if you can reasonably infer something, propose it and let the user correct it (a user fixes a wrong guess faster than they fill a blank).

Group questions into **one round** where possible rather than dripping them out. Use `AskUserQuestion` when the choices are discrete (format, length, audience, tone); use open questions when you need their domain knowledge. The usual gaps worth probing:

- **Audience & purpose** — who reads the output, what will they do with it? ("a summary for a blog post intro" produces a very different prompt than "a summary for a legal filing.")
- **Output shape** — format, length, structure, tone. The single highest-leverage fix on most prompts.
- **Input data** — will they paste real content, or should the prompt carry a placeholder?
- **Constraints / what to avoid** — things that must be included, and things the model should *not* do or say (negative prompting).
- **Standard of success** — what would make them say "yes, exactly that"?

Lead with your best inferred draft answers so the user is reacting to something concrete, not staring at a questionnaire.

### 4. Choose the prompting technique that fits the task

Match the technique to the job and say why in the "what changed" notes — don't bolt all of them onto every prompt:

- **Zero-shot** (instructions + context + output indicator, no examples) — the default for clear, common tasks the model already understands.
- **Few-shot** — when a *format or labeling convention is easier to show than to describe*: classification, sentiment, extraction, structured transforms, matching a specific tone. Include 2–4 short bracketed examples ending with the real input, e.g. `post: "great pen" => Positive`.
- **Chain-of-thought** — when the task needs multi-step reasoning, math, or analysis. Ask the model to reason step by step / show its work before the final answer; accuracy on these tasks rises sharply.
- **Decompose** — when the task is genuinely complex or multi-part, split it into numbered subtasks within the prompt, or into a short sequence of separate prompts. A model asked to do five things at once does each worse.

### 5. Rewrite applying the principles

Produce the improved prompt. The compact checklist (full catalog with before/after pairs in `references/principles.md` — read it when you want examples or feel unsure):

- **Natural, flowing language** — coherent sentences, not isolated keywords. ("What is the sum of these numbers: 4, 8, 12, 16?" beats "Compute the sum total of the subsequent sequence of numerals…")
- **Interrogative framing** — start with who / what / when / where / why / how when it fits; questions focus the model.
- **Context baked in** — the audience/purpose/domain you gathered.
- **Directives for the response type** — name the format, length, and any include/exclude rules.
- **Output indicator last** — put the description of the wanted output at the **end** so it's the model's freshest instruction.
- **Example of the desired output** — when helpful, show one in brackets so it reads as an example, not as input.
- **Negative prompting** — state what to avoid when there's a known failure mode (jargon, opinions, length overruns, off-limits topics).

### 6. Write the file and hand it back

Write the Markdown file in the structure above. In chat, give a one-line summary and the path, and surface the 2–3 highest-impact changes so the user sees the gist without opening the file. Offer to tweak.

## Worked example

**User's draft:** `Summarize this article.`

**After interview** (audience: their company newsletter; length: 3 sentences; tone: upbeat; avoid: internal jargon):

```
You are writing for our company's monthly customer newsletter, whose readers are
non-technical small-business owners. Summarize the article below in exactly three
sentences, in an upbeat, plain-language tone. Avoid internal jargon and acronyms.

Article:
[insert article text]
```

**What changed and why** (excerpt): supplied the missing *audience and purpose* (newsletter, non-technical readers) so the reading level fits; added an *output directive* — "exactly three sentences," upbeat tone — at the end; used a *negative directive* ("avoid jargon") to head off the most likely failure; marked the input with a `[insert article text]` placeholder so the template is reusable.

See `references/principles.md` for the full best-practice catalog with bad/good prompt pairs for each principle.
