# Benchmark Prompts — ORMCP vs Postgres MCP

Companion resources for the article _The Hidden Tax of AI Database Access: An Investigation Across Two MCP Servers, Two Frontier Models, and 20 Controlled Benchmark Runs_ (Tanush Singhal, Medium, April 2026).

**Published article:** [The Hidden Tax of AI Database Access: Two MCP Servers, Two Models, 20 Benchmark Runs](https://medium.com/@tanushsinghal22082004/the-hidden-tax-of-ai-database-access-two-mcp-servers-two-models-20-benchmark-runs-a524169ac6a3)


The Medium slug shortens the headline; the on-page title matches the italicized title above. Methodology, token accounting, versions (ORMCP v0.5.1, Postgres MCP v0.3.0), and results are in that article.

These are the two prompt files used verbatim in the benchmark. Each contains the same four tasks, framed in a different vocabulary for the MCP server under test.

## Files

| File | Vocabulary | Use with |
|---|---|---|
| [`ormcp-prompt.md`](./ormcp-prompt.md) | Object-model (`Customer`, `CustomerOrder`, deep hydration) | ORMCP session |
| [`postgres-prompt.md`](./postgres-prompt.md) | SQL (explicit columns, CTEs, JOINs) | Postgres MCP session |

## Tasks (identical in both files)

- **A** — Known-customer deep read (`id = 2`: profile + addresses + Q3 orders + line items).
- **B** — Find the Q3 order with the highest `totalamount`; return the full graph of the customer who placed it.
- **C** — Top 10 customers by `totalspent` (shallow ranking, explicit projection).
- **D** — Full deep read for customers with `id IN (2, 8, 13)`.

Fixed window: **Q3 2025 analysis window** = `orderdate >= '2025-07-01'` and `orderdate <= '2025-09-30'` (inclusive).

## How to use

1. Point ORMCP at the e-commerce JDX mapping and a PostgreSQL instance loaded with the benchmark schema (see the article’s **Methodology & Reproducibility** section for DDL/data filenames and environment detail).
2. Point Postgres MCP at the same PostgreSQL instance.
3. **Per-task runs (as structured in each `.md` file):** run **Session 1–4** each in its own fresh chat, with only the matching MCP enabled — first the ORMCP prompt file on an ORMCP session, then the Postgres MCP prompt file on a Postgres MCP session (repeat per model if you are reproducing the full study).
4. **All-tasks-in-one-session runs (as in the article):** run Tasks A–D back-to-back in a **single** fresh chat per (model, MCP) pair. That run type is additional to the four isolated sessions; the prompt bodies are the same task text, combined in one conversation for the “agent keeps going” regime. (The prompt files open with “do not combine tasks”; that instruction applies to **per-task** benchmarking. For the combined-session reproduction, deliberately run all four task sections in one session, as described in the article.)
5. Export the provider usage events and apply current list rates to compute token cost.

The models used in the study were **GPT-5.4-medium** and **Claude-4.6-sonnet-medium-thinking**. See the [Medium article](https://medium.com/@tanushsinghal22082004/the-hidden-tax-of-ai-database-access-two-mcp-servers-two-models-20-benchmark-runs-a524169ac6a3) for full methodology, token accounting, and measured results.
