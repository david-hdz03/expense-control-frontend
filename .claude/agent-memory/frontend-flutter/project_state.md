---
name: FlowCash responsive design implementation
description: Responsive web+mobile layouts implemented across all screens with 900px breakpoint; models and API updated for new backend contract
type: project
---

Responsive design implemented across the frontend (2026-04-24).
Models, API, providers and all UI text updated to match new backend contract (2026-04-24).

**Why:** App needed to work on both mobile (<900px) and web (>=900px) with distinct layouts; and the backend API was migrated from /api/expenses to /api/transactions with a different response shape.

**Backend contract change (active as of 2026-04-24):**
- `GET /api/transactions` returns `{ id, amount (int), transaction_type: {id, name}, category: {id, name}|null, user_id, created_at, updated_at }`
- `POST /api/transactions` body: `{ amount, transaction_type_id, category_id? }`
- `GET /api/categories` returns `[{ id, name, is_default, created_at }]`
- `GET /api/auth/me` returns `{ id, name, email, is_active, currency_code, created_at }`

**Model changes:**
- `Expense`: removed description/currency/spentAt, added category (nullable String), categoryId (nullable int); type now uses `fromWire('ingreso'/'gasto')`, `toTypeId()` instead of `toWire()`
- `ExpenseDraft`: simplified to amount/type/categoryId; `toJson()` sends `amount.round()`, `transaction_type_id`
- `User`: added `name` and `currencyCode` fields
- `Category` model added at `lib/models/category.dart`

**Provider changes:**
- `categoriesProvider` added to `expenses_provider.dart`

**UI text:** All screens fully translated to Spanish.

**How to apply:** Responsive breakpoint is always `constraints.maxWidth >= 900` via LayoutBuilder. Web layout never uses ScrollView at the top level — it's a fixed Column with Expanded children.
