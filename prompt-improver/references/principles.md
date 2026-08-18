# Prompt-Engineering Principles — Full Catalog

The compact checklist lives in SKILL.md. This file is the deep reference: each principle with a
bad/good pair so you can show the user a concrete contrast. Read it when you want examples or feel
unsure how to apply a principle.

## Table of contents
1. Be clear and concise
2. Include context if needed
3. Use directives for the response type
4. Put the requested output at the end
5. Start with an interrogation
6. Provide an example response
7. Break up complex tasks
8. The four elements of a prompt
9. Prompting techniques (zero-shot, few-shot, chain-of-thought)
10. Negative prompting

---

## 1. Be clear and concise
Prompts should be straightforward and avoid ambiguity. Use natural, flowing language and coherent
sentence structure. Avoid isolated keywords and stiff, padded phrasing.

- **Bad:** `Compute the sum total of the subsequent sequence of numerals: 4, 8, 12, 16.`
- **Good:** `What is the sum of these numbers: 4, 8, 12, 16?`

## 2. Include context if needed
Provide any additional context that helps the model respond accurately. If you ask it to analyze a
business, say what the business does. Context can be common across many inputs or specific to one.

- **Bad:** `Summarize this article: [insert article text]`
- **Good:** `Provide a summary of this article to be used in a blog post: [insert article text]`

## 3. Use directives for the response type
If you want a particular form — a summary, a question, a poem — say so directly. You can also bound
the response by length, format, information to include, and information to exclude.

- **Bad:** `What is the capital?`
- **Good:** `What is the capital of New York? Provide the answer in a full sentence.`

## 4. Put the requested output at the end
Mentioning the requested output at the end of the prompt keeps the model focused on the right content.

- **Bad:** `Calculate the area of a circle.`
- **Good:** `Calculate the area of a circle with a radius of 3 inches (7.5 cm). Round your answer to the nearest integer.`

## 5. Start with an interrogation
Phrase the input as a question — begin with who, what, where, when, why, or how. It focuses the model
on producing a direct answer.

- **Bad:** `Summarize this event.`
- **Good:** `Why did this event happen? Explain in three sentences.`

## 6. Provide an example response
Show the expected output format as an example inside the prompt. Surround it in brackets so it reads
as an example rather than as input data.

- **Bad:** `Determine the sentiment of this social media post: [insert post]`
- **Good:**
  ```
  Determine the sentiment of the following social media post using these examples:
  post: "great pen" => Positive
  post: "I hate when my phone battery dies" => Negative
  [insert social media post] =>
  ```

## 7. Break up complex tasks
Models get confused by big tangled tasks. Techniques:
- **Divide into subtasks.** If one prompt won't produce reliable results, split it into several prompts.
- **Confirm understanding.** Ask the model whether it understood the instruction, then clarify based on its reply.
- **Ask it to reason systematically.** If you can't decompose it yourself, instruct the model to think step by step / approach the problem systematically / reason through it one step at a time.

## 8. The four elements of a prompt
A complete prompt usually has all four. Use them as a diagnostic — find which are missing.
- **Instruction** — the task for the model to perform.
- **Context** — external information that guides the model.
- **Input data** — the specific input you want a response for.
- **Output indicator** — the desired output type or format.

## 9. Prompting techniques
- **Zero-shot** — instruction + context + output indicator, no examples. Best for clear, common tasks.
- **Few-shot** — include a handful of input→output examples so the model infers the pattern. Best when
  a format or labeling convention is easier to demonstrate than to describe (classification, sentiment,
  extraction, structured transforms, tone-matching). The sentiment block in §6 is a few-shot prompt.
- **Chain-of-thought** — ask the model to show its reasoning step by step before the final answer. Best
  for math, logic, and multi-step analysis, where reasoning out loud raises accuracy.

Experiment and be creative: try several phrasings, keep what produces accurate results, drop what
doesn't. Novel framings can unlock better outputs.

## 10. Negative prompting
Sometimes it's easier to steer the model by stating what you do **not** want. Negative prompting guides
the model away from certain content or behaviors — telling it what not to generate. Examples: "avoid
technical jargon," "do not include personal opinions," "do not exceed 200 words," "don't produce biased
or explicit language." Use it whenever a task has a predictable failure mode you want to pre-empt.
