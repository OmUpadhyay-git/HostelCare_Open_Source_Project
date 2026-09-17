# Phases.md — HostelCare
## Development Roadmap

The project is built in phases. Each phase must be completed, tested, and reported on before the next begins — the AI should never auto-cascade to the next phase (see `Rules.md` §9).

**Per-phase execution pattern:**
1. Inspect existing project
2. Read relevant docs
3. Inspect only files necessary for this phase
4. Explain current implementation
5. Identify required changes
6. Create implementation plan
7. Implement
8. Run `flutter analyze`
9. Run relevant tests
10. Fix errors
11. Verify manually where possible
12. Update documentation (incl. `Memory.md`)
13. Provide completion report → **STOP**

---

## Phase 0 — Requirements & Architecture
Assess existing project (if any). Produce: functional requirements, roles, complaint lifecycle, system architecture, Flutter architecture, Supabase architecture, database ER design, RLS security model, navigation structure, data-access strategy, roadmap, risks. *(This is the phase covered by `PRD.md` and `Architecture.md`.)*

## Phase 1 — Flutter Project Setup ✅ COMPLETE
Initialize Flutter project, base folder structure, environment config (dev/prod), linting rules, core dependencies (Riverpod, GoRouter).

## Phase 2 — Design System + UI Foundation ✅ COMPLETE
Implement `Design.md` as a Flutter theme: colors, typography, spacing, shared components (buttons, cards, inputs, status badges, empty/loading/error states).

## Phase 3 — Supabase Project + Database ✅ COMPLETE
Create Supabase project(s) for dev/prod. Build core schema: hostels, blocks, floors, rooms, users, categories — with constraints and indexes per `Architecture.md`.

## Phase 4 — Authentication
Supabase Auth integration: login, logout, session persistence/restoration, session expiration handling, password reset. Secure storage for tokens.

## Phase 5 — RLS + Security
Write and test RLS policies for every table before any feature that touches it goes live. This phase underpins every phase after it.

## Phase 6 — Student Module
Student dashboard, profile (read-only fields), raise complaint flow, complaint list/detail, image upload for new complaints.

## Phase 7 — Warden Module
Warden dashboard, complaint queue scoped to authorized hostel/block, accept/reject, remarks.

## Phase 8 — Staff Module
Staff dashboard, assigned-complaint list, accept/start work, progress remarks and images.

## Phase 9 — Complaint Workflow
Implement the full status state machine end-to-end with backend-enforced valid transitions (PENDING → ... → CLOSED, plus REJECTED/CANCELLED/REOPENED/ON_HOLD).

## Phase 10 — Complaint History + Audit
Append-only `complaint_history` table wired into every state-changing action; complaint timeline UI.

## Phase 11 — Image Upload
Full Supabase Storage integration: MIME/size validation, compression, private access policies, storage path + metadata tracking.

## Phase 12 — Notifications
In-app notifications first (table + realtime). Evaluate and implement push notifications afterward (device registration, multi-device support, token refresh, graceful failure).

## Phase 13 — Resolution + Reopen
Resolution submission flow, student verify/reject UI, reopen flow with optional reason.

## Phase 14 — Admin Module
Full CRUD for students, wardens, staff, hostels, blocks, rooms, categories, SLA/priority config; user deactivation/reactivation.

## Phase 15 — Search + Filtering
Server-side filtering (status, category, priority, hostel, block, room, assigned warden/staff, date range, SLA status) with pagination across all list views.

## Phase 16 — SLA + Escalation
SLA deadline calculation and display (Within SLA / Overdue), two-level escalation notifications (warden → admin) on breach.

## Phase 17 — Feedback
Post-closure rating + comment flow, one-per-complaint constraint, admin visibility.

## Phase 18 — Analytics + Reports
Admin dashboard metrics and reports (by category, hostel, block, status, priority; average resolution time; SLA compliance) with date-range filters. Real data only (per `Rules.md` §4).

## Phase 19 — Offline / Error Handling
Comprehensive network-failure handling, retry mechanisms, duplicate-submission protection, user-friendly error mapping.

## Phase 20 — Security Audit
Explicit role-boundary testing: student→admin data, student→other student, warden→unauthorized hostel, staff→unassigned complaint, unauthenticated→protected resource. All must fail.

## Phase 21 — Testing
Full unit/widget/integration test suite: auth, complaint creation, status transitions, permissions/RLS, image upload, notifications, feedback, SLA calculation.

## Phase 22 — Performance Optimization
List rendering, query optimization, image handling, network call reduction, state/widget rebuild efficiency, safe caching of read-only data.

## Phase 23 — Android Release
App name, package ID, icon, splash screen, permissions, release signing, versioning; debug and release build testing across screen sizes.

## Phase 24 — iOS Release
Bundle ID, icon, splash screen, permissions, versioning; simulator and device testing. Flag Apple Developer Program cost/requirements.

## Phase 25 — Production Documentation
Final documentation pass: setup guide, environment config guide, RLS policy reference, known limitations, handover notes.

---

## MVP Definition (subset of the above, must be stable first)

```
Student Login → Profile → Raise Complaint → Stored Securely
→ Warden Login → Receives Complaint → Accepts → Assigns Staff
→ Staff Starts Work → Resolves → Student Notified → Student Verifies → Closed
```

This corresponds to Phases 0–10 plus the minimum of Phase 11 (images) and Phase 12 (in-app notifications only). Advanced analytics (Phase 18) and beyond are explicitly deferred until this workflow is stable.
