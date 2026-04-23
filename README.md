# Benchmark Prompts — ORMCP vs Postgres MCP

Companion resources for the article _The Hidden Tax of AI Database Access: An Investigation Across Two MCP Servers, Two Frontier Models, and 20 Controlled Benchmark Runs_ (Tanush Singhal, Medium, April 2026).

**Published article:** [The Hidden Tax of AI Database Access: Two MCP Servers, Two Models, 20 Benchmark Runs](https://medium.com/@tanushsinghal22082004/the-hidden-tax-of-ai-database-access-two-mcp-servers-two-models-20-benchmark-runs-a524169ac6a3)


These are the two prompt files used verbatim in the benchmark. Each contains the same four tasks, framed in a different vocabulary for the MCP server under test.

## Files

| File | Purpose | Use with |
|---|---|---|
| [`ormcp-prompt.md`](./ormcp-prompt.md) | Object-model prompt (`Customer`, `CustomerOrder`, deep hydration) | ORMCP session |
| [`postgres-prompt.md`](./postgres-prompt.md) | SQL-vocabulary prompt (explicit columns, CTEs, JOINs) | Postgres MCP session |
| [`database/schema.sql`](./database/schema.sql) | PostgreSQL DDL for the benchmark schema (suppliers, products, customers, addresses, orders, order items) + `JDXMetadata` | `psql` against a fresh database |
| [`database/data.sql`](./database/data.sql) | Idempotent seed script producing the exact benchmark dataset (16 suppliers, 32 products, 28 customers, 37 addresses, 36 Q3 2025 orders, 68 order items) | Run after `schema.sql` |

### Reproducing the benchmark database

```bash
# 1. Create an empty PostgreSQL database, e.g.:
createdb ecommerce

# 2. Load the schema (drops and recreates all tables, then creates JDXMetadata):
psql -d ecommerce -f database/schema.sql

# 3. Seed the benchmark dataset (TRUNCATEs all benchmark tables and repopulates deterministically):
psql -d ecommerce -f database/data.sql
```

Expected row counts after loading:

| Table | Rows |
|---|---|
| `supplier` | 16 |
| `product` | 32 |
| `customer` | 28 |
| `address` | 37 (one shipping per customer + billing for every 3rd customer) |
| `customerorder` | 36 (all dated in Q3 2025: `2025-07-01` through `2025-09-30`) |
| `orderitem` | 68 |
| `JDXMetadata` | 0 (managed by Gilhari/JDX at runtime) |

> **JDX safety note.** `schema.sql` creates a `JDXMetadata` table at the end via `CREATE TABLE IF NOT EXISTS`. This table must exist before Gilhari/JDX connects to the schema — if it is missing, JDX may treat the schema as unmanaged and drop existing tables during ORM initialization. The statement was verified on PostgreSQL (all five `TEXT` columns — `jdxORMId`, `jdxTimestamp`, `jdxMetaVersionId`, `jdxMetaFileName`, `jdxMetaInfo` — materialize correctly, and re-runs are a no-op).

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
