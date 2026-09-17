# Memory.md — HostelCare
## Progress & Context Log

> **Note:** Per the project workflow, this file is not meant to be filled out at project start — it's meant to be updated continuously **once coding begins**, at the end of every phase (and ideally after any significant sub-step). Its purpose is to let the AI (in this session or a fresh one) pick up exactly where things left off without re-reading the entire codebase or guessing at prior decisions.
>
> Below is the starter structure. Update the relevant sections as work happens — do not let this file go stale.

---

## How to Use This File

- Update **after every completed phase step** (per the execution pattern in `Phases.md`).
- Keep entries factual and specific: what was built, what decisions were made and why, what is still broken or pending.
- Do not restate the full contents of `PRD.md` / `Architecture.md` / `Rules.md` / `Phases.md` / `Design.md` here — link to the relevant section instead. This file is a **delta log**, not a duplicate of the specs.
- When starting a new chat/session, read this file first, before re-inspecting the codebase.

---

## Current Status

**Current phase:** Phase 3 — Supabase Project + Database ✅ COMPLETE
**Last updated:** 2026-09-17

---

## Completed Phases

| Phase | Status | Notes |
|---|---|---|
| 0 — Requirements & Architecture | ✅ Complete (docs only) | `PRD.md`, `Architecture.md`, `Rules.md`, `Phases.md`, `Design.md` written. No code yet. |
| 1 — Flutter Project Setup | ✅ Complete | Flutter project created, folder structure, theme, router, error architecture, shared components. |
| 2 — Design System + UI Foundation | ✅ Complete | Complete ColorScheme, typography system, status/priority enums, 10+ reusable components, role screens. |
| 3 — Supabase Project + Database | ✅ Complete | Full PostgreSQL schema, migrations, seed data, Supabase Flutter integration. |
| 4 — Authentication | ⬜ Not started | |
| ... | ⬜ | Continue this table as phases progress |

---

## Key Decisions Log

- `2026-09-17` — Used `flutter_secure_storage` per `Rules.md` §2 for secure token storage.
- `2026-09-17` — Theme uses dark mode as default per `Design.md` §1 (operational, always-on nature of warden/staff use).
- `2026-09-17` — Environment config uses compile-time dart-define (no flutter_dotenv dependency to keep Phase 1 minimal).
- `2026-09-17` — Placeholder screens created for all route groups to verify GoRouter architecture works.
- `2026-09-17` — Created `ComplaintStatus` and `ComplaintPriority` enums with centralized label/color/icon per Design.md.
- `2026-09-17` — All components use theme-aware colors, never hardcoded values (except semantic status colors).
- `2026-09-17` — Skeleton loaders implemented with animation for better perceived performance.
- `2026-09-17` — Database uses UUID primary keys for all tables per Architecture.md.
- `2026-09-17` — Complaint numbers generated via PostgreSQL sequence for guaranteed uniqueness.
- `2026-09-17` — Soft-delete pattern (`is_active`) used for hostels, blocks, floors, rooms, staff.
- `2026-09-17` — No `ON DELETE CASCADE` on complaint-related tables (historical data preserved).
- `2026-09-17` — All timestamps use `TIMESTAMPTZ` for timezone awareness.

---

## Known Issues / Open Items

- Environment variables (SUPABASE_URL, SUPABASE_ANON_KEY) must be provided via `--dart-define` at build time; no `.env` file loading.
- Supabase project must be created manually in Supabase dashboard before migrations can be applied.
- RLS policies not yet implemented (Phase 5).
- Storage policies are minimal placeholders for development (Phase 5 will complete them).

---

## Environment / Setup Notes

- Flutter 3.47.4 (stable channel)
- Dart 3.13.3
- Supabase dev project: _not yet created_
- Supabase prod project: _not yet created_

### Build Commands

```bash
# Development build with environment variables
flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>

# Production build
flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key> --dart-define=PROD=true
```

### Database Setup

1. Create Supabase project at https://supabase.com
2. Run migrations in order:
   - `supabase/migrations/001_initial_schema.sql`
   - `supabase/migrations/002_seed_data.sql`
   - `supabase/migrations/003_storage.sql`

---

## Dependencies Added

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | ^2.6.1 | State management |
| go_router | ^14.8.1 | Navigation |
| flutter_secure_storage | ^9.2.4 | Secure token storage |
| intl | ^0.20.2 | Date formatting |
| supabase_flutter | ^2.8.4 | Supabase client |

---

## Database Schema Summary

### Tables (13)
1. `profiles` — User profiles linked to auth.users
2. `hostels` — Hostel buildings
3. `blocks` — Blocks within hostels
4. `floors` — Floors within blocks
5. `rooms` — Rooms within floors
6. `students` — Student-specific data
7. `wardens` — Warden-specific data
8. `staff` — Staff-specific data
9. `complaint_categories` — Configurable complaint categories
10. `complaints` — Core complaint entity
11. `complaint_images` — Image metadata for complaints
12. `complaint_history` — Append-only audit trail
13. `notifications` — In-app notifications
14. `feedback` — Post-closure feedback
15. `audit_logs` — Administrative audit trail

### Enums (4)
- `user_role` — student, warden, staff, admin
- `complaint_status` — 11 statuses
- `complaint_priority` — low, medium, high, urgent
- `complaint_image_type` — complaint, progress, resolution

### Indexes (23)
- Optimized for common query patterns
- Complaint queries: student_id, category_id, assigned_warden_id, assigned_staff_id, status, priority, created_at
- Notification queries: user_id, is_read
- History queries: complaint_id

---

## Files Created (Phase 3)

### Database Migrations
- `supabase/migrations/001_initial_schema.sql` — All tables, enums, functions, indexes
- `supabase/migrations/002_seed_data.sql` — Initial complaint categories
- `supabase/migrations/003_storage.sql` — Storage bucket and policies

### Documentation
- `markdown files/DATABASE_DESIGN.md` — Complete database documentation

### Updated Files
- `lib/main.dart` — Supabase initialization
- `lib/app/config/env.dart` — Updated with supabasePublishableKey
- `pubspec.yaml` — Added supabase_flutter dependency

---

## Tests

15 widget tests passing:
- AppButton (4 tests)
- StatusBadge (3 tests)
- ComplaintCard (1 test)
- EmptyState (1 test)
- ErrorState (1 test)
- LoadingIndicator (2 tests)
- Timeline (1 test)
- SectionHeader (1 test)
- App smoke test (1 test)

---

## Next Action

Begin **Phase 4 — Authentication** per `Phases.md`.
