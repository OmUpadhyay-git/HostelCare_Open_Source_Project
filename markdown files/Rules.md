# Rules.md — HostelCare
## Boundaries for AI-assisted development

---

## 1. General Principles

- Build **production-quality**, not demo/CRUD-quality code. This is a real operational tool.
- Do not over-engineer. No microservices, no Kubernetes, no message buses, no unnecessary backend servers, no AI features without a documented requirement, no unnecessary third-party packages. Start with Flutter + Supabase and add complexity only when a real requirement demands it.
- Never assume a feature is complete without actually testing it.
- Never skip development phases (see `Phases.md`). Complete and report on one phase before starting the next — do not auto-cascade.
- Never fabricate progress. If something isn't implemented or tested, say so explicitly.

---

## 2. Security Rules (Non-Negotiable)

- **UI restrictions are never security.** `if role == ADMIN: show admin screen` in Flutter is a UX convenience only. Every permission must be enforced by Supabase RLS policies and/or database constraints.
- Every sensitive table must have RLS policies before it is used in the app, not added later "when there's time."
- Never trust client input. All validation must exist server-side/database-side even if it also exists in Flutter.
- Never store plaintext passwords, log passwords, or log auth tokens.
- Never store sensitive tokens in `SharedPreferences` — use secure storage (`flutter_secure_storage`).
- Never expose Supabase service role keys, database passwords, or other secrets in code, commits, or client-side config.
- Never expose raw database/storage errors, stack traces, or internal service details to end users.
- Storage buckets for complaint images must not be publicly readable unless there is a specific, stated reason — use signed/private URLs.

---

## 3. Data Integrity Rules

- Status transitions must go through a validated state machine — invalid transitions (e.g. `PENDING → CLOSED`, a student setting `IN_PROGRESS → RESOLVED` directly) must be rejected by the backend, not just discouraged in the UI.
- `complaint_history` is append-only. No update/delete of history rows by normal application roles.
- Never hard-delete users, hostels, blocks, rooms, or categories that have historical complaint relationships. Use `is_active` soft-deactivation.
- Never hardcode hostel names, block names, room numbers, categories, SLA hours, or staff/warden assignments anywhere in the Flutter app — these are database-driven, admin-configurable values.
- Complaint numbers must be generated uniquely (e.g. `HC-2026-000001`) and never collide.

---

## 4. Data Honesty Rules

- Never display fabricated statistics on dashboards. If the database has no data, show "No complaint data available," not an invented number.
- Dummy/mock data is acceptable only during isolated UI development and must be clearly marked and removed before connecting to real data flows.

---

## 5. Tech Stack Boundaries

**Use:**
- Flutter, Riverpod, GoRouter
- Supabase (Auth, PostgreSQL, Storage, RLS, Edge Functions only if genuinely required)
- Material 3 components

**Avoid unless explicitly justified in writing:**
- A custom Node.js/Express (or similar) backend
- Any state management library other than Riverpod
- Any routing solution other than GoRouter
- Firebase as a database (Supabase/PostgreSQL is the system of record)
- Storing image binaries in PostgreSQL — always Supabase Storage
- Non-free-tier services in MVP/early phases without flagging the cost first

---

## 6. Code Quality Rules

- Feature-based folder structure (see `Architecture.md`) — no dumping everything into one folder.
- Business/data logic lives in repositories and Riverpod providers — never large blocks of Supabase queries inside widget build methods.
- Run `flutter analyze` and fix warnings/errors before declaring a phase complete.
- Write unit/widget/integration tests for auth, complaint creation, status transitions, permissions/RLS, image upload, notifications, feedback, and SLA calculation — per `Phases.md`.
- Meaningful commit messages (`feat: ...`, `fix: ...`) — never commit build artifacts, `.env` files, secrets, or temporary test data.

---

## 7. UX Rules

- Material 3, consistent spacing, accessible touch targets, clear typography, proper contrast.
- Always implement loading, error, and empty states — never leave a screen with no feedback for these cases.
- Never rely on color alone to convey status (e.g. urgency must show the word "URGENT," not just red).
- Avoid excessive gradients, animation, shadows, or decoration — prioritize operational clarity over visual flourish (see `Design.md` for the actual visual system).
- Confirmation dialogs are required before destructive/irreversible actions.

---

## 8. Network & Reliability Rules

- Every network-dependent action must handle: no internet, slow internet, timeout, server error, session expiration — with a user-facing message, never a raw exception.
- Never silently lose user-entered data (e.g. a half-written complaint) on a failed submission — preserve it and allow retry.
- Disable submit buttons while a request is in flight; prevent duplicate complaint creation from double-taps or retries.

---

## 9. What the AI Should Do at Each Step

- Inspect the existing project state before making changes.
- Read relevant documentation/skills before writing code for a new file type or integration.
- Explain the current implementation and the planned change before implementing it.
- Implement, then run `flutter analyze` and relevant tests, then fix issues.
- Update documentation (including `Memory.md`) and provide a completion report.
- Stop. Do not proceed to the next phase without explicit approval.

## 10. What the AI Should NOT Do

- Do not build the entire application in one pass.
- Do not skip Phase 0 assessment before writing code.
- Do not introduce a dependency, package, or architectural pattern not listed in `Architecture.md` without flagging it first.
- Do not assume iOS distribution is free — flag Apple Developer Program costs when relevant.
- Do not mark a phase "complete" without tests having been run.
