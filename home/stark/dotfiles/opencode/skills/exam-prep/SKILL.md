---
name: exam-prep
description: Turns a folder of lecture slides and past-year exam papers into intuitive, concept-first exam prep. Use this whenever the user wants to prepare/cram/study for an exam, asks to go through past papers, wants concepts from slides explained simply, or mentions "exam prep", "past papers", "previous year questions", or wants a slides.md summary made from a course's material. Trigger even if they only say something like "help me study for my exam" or "go through this course's slides and papers" without naming the skill.
---

# Exam Prep

Turns raw course material (lecture slides + past exam papers, all sitting in one
working directory) into exam-ready understanding: the underlying concepts,
explained simply, anchored to how they've actually been tested — not a slide
dump.

## Philosophy (read this before doing anything else)

- **Past papers are the holy grail.** Exams recycle patterns. Every problem is
  really testing one or a few underlying concepts dressed up in different
  surface details. The job is to reverse-engineer which concepts each problem
  is really testing, not to memorize problems.
- **Concepts outlive courses.** The student will forget the fine print after
  the exam. What should stick is the intuitive core idea. Every explanation
  should optimize for "this makes sense and I'll still get it in a year," not
  for reciting the slide's wording back.
- **Never just paraphrase slide bullets.** Slides are raw material, not the
  final teaching. Synthesize: what is this concept actually *for*, why does it
  work, what's the simplest mental model that predicts the right answer under
  exam pressure.

## Step 1 — Find and classify the materials

Everything lives mixed together in one working directory (no fixed
subfolders). List the directory and classify each file by filename and a
quick peek at content:

- **Slides**: filenames like `lecture*`, `L1`, `L2`, `chapter*`, `unit*`,
  `week*`, `slides*`, or `.pptx`/slide-formatted `.pdf` files.
- **Past papers**: filenames with a year, or containing `exam`, `endsem`,
  `midterm`, `quiz`, `test`, `paper`, `qp`, `question`.
- **Reference books / textbooks**: larger `.pdf`s with a book-like title/ISBN,
  or ones the user explicitly points out. These are optional — if none exist,
  skip that layer without complaint.

If the folder clearly contains material from **more than one course**, stop
and ask the user which course to focus on before doing any real work — don't
guess and mix two courses' concepts together.

If you can't confidently classify something, open it and check rather than
guessing from the filename alone.

## Step 2 — Build the concept map from the slides

Read through the slides and extract the actual list of concepts taught
(not slide titles verbatim — the underlying ideas). Note which slide(s) each
concept lives on, since you'll cite this later.

## Step 3 — Mine the past papers for patterns

For every question in every past paper:

1. Identify which concept(s) from your Step 2 map it's really drawing on
   (a question can touch more than one).
2. Group questions across years by the concept(s) they hit. This is where the
   patterns show up — the same 2-3 concepts tend to get re-tested in
   different costumes every year.

Use this grouping to **rank concepts by how often and how heavily they're
tested**. This ranking sets your teaching order in Step 4 — highest-yield
concepts first. If no past papers exist in the folder, fall back to slide
order and tell the user you're doing so.

## Step 4 — Teach each concept (in chat, not saved to a file)

Go concept by concept, in priority order from Step 3. For each one:

1. **Pull what the slides say**, citing which slide(s) (e.g. "Lecture 4,
   slide 12"). If a reference book is available and adds real clarity beyond
   the slides, pull from it too and say so.
2. **Explain it in ultra-simple, intuitive terms.** Assume the student wants
   the "aha" version, not the textbook version. Use a concrete analogy or a
   minimal example where it helps. State the core idea in one or two plain
   sentences before you formalize anything.
3. **Show one worked past-paper-style problem** for this concept, solved step
   by step, showing the reasoning — not just the final answer.
4. **End with "Your turn":** pose a new problem testing the *same* concept
   and pattern but with different surface details (different numbers, a
   different scenario, etc.), then immediately give the worked solution below
   it, so the student can self-check right away.

Keep the whole thing conversational — this content is delivered in chat and
is not saved as a file. Don't move to the next concept until this one is
fully done.

## Step 5 — Produce slides.md

After (or alongside) the concept walkthrough, create a single `slides.md`
file — this is the one artifact that gets saved. For every slide, in order,
give a short summarized bullet version of its content (not verbatim text),
organized under headers by lecture/unit. This is meant as a compact
skim-before-the-exam reference, distinct from the deep concept teaching above.

Save it to the output location and share it with the user.

## Edge cases

- **Scanned or image-heavy slides**: read them visually rather than skipping
  — don't silently drop content because it isn't selectable text.
- **No reference books present**: proceed on slides + past papers alone, and
  say so rather than inventing textbook content.
- **No past papers present**: say so, teach in slide order, and note that
  exam-pattern prioritization wasn't possible.
- **A concept never appears in any past paper**: still teach it (it may just
  be a new-syllabus addition or a fundamentals concept), but don't rank it
  above concepts with a proven track record of being tested.

## Tone rules

- Never dump raw slide text verbatim — always synthesize in your own words.
- Intuition before formalism: the plain-English "why" comes before any
  formula or definition, not after.
- Be concise per concept — thorough, not padded.
