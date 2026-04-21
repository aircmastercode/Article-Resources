# Benchmark Prompts — ORMCP vs Postgres MCP

Companion resources for the article _The Hidden Tax of AI Database Access: An Investigation Across Two MCP Servers, Two Frontier Models, and 20 Controlled Benchmark Runs_.

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

1. Point ORMCP at the e-commerce JDX mapping and a PostgreSQL instance loaded with the benchmark schema.
2. Point Postgres MCP at the same PostgreSQL instance.
3. Run each prompt in its own fresh chat session, first on the ORMCP-connected agent and then on the Postgres-MCP-connected agent.
4. Export the provider usage events and apply current list rates to compute token cost.

The models used in the study were **GPT-5.4-medium** and **Claude-4.6-sonnet-medium-thinking**. See the full article for methodology, token accounting, and measured results.
