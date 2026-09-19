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

**Current phase:** Phase 6 — Student Module ✅ COMPLETE (pending live Supabase testing)
**Last updated:** 2026-09-19

---

## Completed Phases

| Phase | Status | Notes |
|---|---|---|
| 0 — Requirements & Architecture | ✅ Complete (docs only) | `PRD.md`, `Architecture.md`, `Rules.md`, `Phases.md`, `Design.md` written. No code yet. |
| 1 — Flutter Project Setup | ✅ Complete | Flutter project created, folder structure, theme, router, error architecture, shared components. |
| 2 — Design System + UI Foundation | ✅ Complete | Complete ColorScheme, typography system, status/priority enums, 10+ reusable components, role screens. |
| 3 — Supabase Project + Database | ✅ Complete | Full PostgreSQL schema, migrations, seed data, Supabase Flutter integration. |
| 4 — Authentication | ✅ Complete | Profile model, AuthRepository, AuthState/Riverpod providers, Login/Forgot Password screens, auth guards, role-based routing. |
| 5 — RLS + Security | ✅ Complete | RLS enabled on all 15 tables, 6 helper functions, 50+ policies, privilege escalation trigger, storage policies, verification test script. Pending live DB testing. |
| 6 — Student Module | ✅ Complete | Student dashboard, complaint CRUD, search/filter, timeline, verify/reopen/cancel actions, 55 tests passing. Pending live Supabase testing. |
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
- `2026-09-18` — Profile model includes UserRole extension with label, routePrefix, icon, and fromString.
- `2026-09-18` — Auth state uses custom AuthState class (not Supabase's) to avoid naming conflicts.
- `2026-09-18` — Router uses Riverpod Provider for dynamic auth-based redirects.
- `2026-09-18` — Login/ForgotPassword use TextFormField with Form validation (not AppTextField which lacks validator).
- `2026-09-18` — Auth tests are pure unit tests (no Supabase instance required) to avoid test flakiness.
- `2026-09-18` — **AUDIT FIX:** `UserRole.fromString` now returns `null` for invalid roles instead of silently defaulting to `student`. `Profile.fromJson` throws `ArgumentError` for invalid roles.
- `2026-09-18` — **AUDIT FIX:** Router now prevents cross-role route access (student cannot access `/warden/*` etc.).
- `2026-09-18` — **AUDIT FIX:** `AuthNotifier` now subscribes to Supabase auth state stream for session refresh/sign-out handling.
- `2026-09-18` — **AUDIT FIX:** Removed `updateLastLogin` method (referenced non-existent `last_login_at` column).
- `2026-09-18` — **AUDIT FIX:** Cleaned up unused imports in `widget_test.dart`.
- `2026-09-18` — **Phase 5:** RLS helper functions use `SECURITY DEFINER` + `SET search_path = public` to prevent manipulation.
- `2026-09-18` — **Phase 5:** Identity derived from `auth.uid()` — never from client-supplied values in RLS policies.
- `2026-09-18` — **Phase 5:** All 15 application tables have RLS enabled with `FORCE ROW LEVEL SECURITY` on table owners.
- `2026-09-18` — **Phase 5:** `prevent_role_escalation` trigger blocks non-admin users from modifying `role` or `is_active` on profiles.
- `2026-09-18` — **Phase 5:** Complaint history is append-only for non-admins (no UPDATE/DELETE policies).
- `2026-09-18` — **Phase 5:** Storage policies use `(storage.foldername(name))[1]` to match complaint IDs, ensuring complaint-scoped access.
- `2026-09-18` — **Phase 5:** Reference data (hostels, blocks, floors, rooms, categories) readable by all authenticated users, writable by admins only.
- `2026-09-18` — **Phase 5:** Wardens can create complaints on behalf of students in their hostel scope.
- `2026-09-18` — **Phase 5:** `005_rls_verification_tests.sql` created with 15 test scenarios for live verification.
- `2026-09-19` — **Phase 6:** Created Complaint, ComplaintCategory, ComplaintHistory, ComplaintImage, Student, and Location models.
- `2026-09-19` — **Phase 6:** ComplaintRepository handles all complaint CRUD with Supabase queries using joined data for display.
- `2026-09-19` — **Phase 6:** StudentRepository fetches student record with joined hostel/block/floor/room data.
- `2026-09-19` — **Phase 6:** ComplaintProvider exposes categories, complaint list with filtering/pagination, complaint detail, history, and create complaint state.
- `2026-09-19` — **Phase 6:** StudentDashboard shows real data from Supabase (student info, complaint counts, recent complaints).
- `2026-09-19` — **Phase 6:** CreateComplaintScreen loads categories from database, validates form, creates complaint with server-generated number.
- `2026-09-19` — **Phase 6:** MyComplaintsScreen supports search by title/number, filter by status/priority, pagination.
- `2026-09-19` — **Phase 6:** ComplaintDetailScreen shows full complaint info with timeline from complaint_history table.
- `2026-09-19` — **Phase 6:** Verify/Reopen/Cancel actions use database RPC functions for status transition validation.
- `2026-09-19` — **Phase 6:** All complaint identity (student_id, hostel_id, etc.) derived from authenticated student's database record — never from client input.
- `2026-09-19` — **Phase 6:** Fixed `fromString` methods — converted to top-level functions (`parseComplaintStatus`, `parseComplaintPriority`) for proper accessibility.
- `2026-09-19` — **Phase 6:** Added 19 complaint model tests bringing total to 55 tests passing.

---

## Known Issues / Open Items

- Environment variables (SUPABASE_URL, SUPABASE_ANON_KEY) must be provided via `--dart-define` at build time; no `.env` file loading.
- Supabase project must be created manually in Supabase dashboard before migrations can be applied.
- RLS policies implemented in `004_rls_security.sql` — live verification pending (Supabase project not yet created).
- Storage policies replaced from minimal Phase 3 placeholders to complaint-scoped authorization.
- Verification test script (`005_rls_verification_tests.sql`) requires test users to be created in Supabase dashboard before running.
- **Phase 6:** Live Supabase integration testing not yet performed — no dev project created.
- **Phase 6:** Notifications and Profile screens remain as placeholders (not in Phase 6 scope).
- **Phase 6:** `verify_complaint`, `reopen_complaint`, `cancel_complaint` RPC functions referenced in repository — must be created in database when Supabase project is set up.

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
   - `supabase/migrations/004_rls_security.sql` — RLS policies
3. Create test users in Supabase dashboard
4. Run `supabase/migrations/005_rls_verification_tests.sql` to verify authorization

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
- `supabase/migrations/004_rls_security.sql` — RLS policies for all tables
- `supabase/migrations/005_rls_verification_tests.sql` — Authorization verification test script

### Documentation
- `markdown files/DATABASE_DESIGN.md` — Complete database documentation

### Updated Files
- `lib/main.dart` — Supabase initialization
- `lib/app/config/env.dart` — Updated with supabasePublishableKey
- `pubspec.yaml` — Added supabase_flutter dependency

---

## Files Created (Phase 4)

### Models
- `lib/models/profile.dart` — Profile model with UserRole enum and extension

### Repositories
- `lib/repositories/auth_repository.dart` — Supabase Auth wrapper with error mapping

### Providers
- `lib/providers/auth_provider.dart` — AuthNotifier, AuthState, auth/profile/role providers

### Features
- `lib/features/auth/login_screen.dart` — Email/password login with validation
- `lib/features/auth/forgot_password_screen.dart` — Password reset flow with success state

### Updated Files
- `lib/app/router/app_router.dart` — Auth guards, role-based redirect, login/forgot-password routes
- `lib/app/hostelcare_app.dart` — Uses routerProvider instead of static AppRouter.router

---

## Files Created (Phase 6)

### Models
- `lib/models/complaint.dart` — Complaint data model with joined data support
- `lib/models/complaint_category.dart` — Category model from complaint_categories table
- `lib/models/complaint_history.dart` — History/audit trail model
- `lib/models/complaint_image.dart` — Image metadata model
- `lib/models/student.dart` — Student-specific data model
- `lib/models/location.dart` — Hostel, Block, Floor, Room models
- `lib/models/models.dart` — Barrel file for all models

### Repositories
- `lib/repositories/complaint_repository.dart` — Complaint CRUD, categories, history, images, actions
- `lib/repositories/student_repository.dart` — Student record with joined location data

### Providers
- `lib/providers/complaint_provider.dart` — Categories, complaint list (filtered/paginated), detail, history, create state
- `lib/providers/student_provider.dart` — Student record provider

### Features/Student
- `lib/features/student/dashboard/student_home_screen.dart` — Real data dashboard with student info, complaint stats, recent complaints
- `lib/features/student/complaints/create_complaint_screen.dart` — Form with category selection, validation, image upload support
- `lib/features/student/complaints/my_complaints_screen.dart` — List with search, filter, pagination
- `lib/features/student/complaints/complaint_detail_screen.dart` — Full detail view with timeline, actions
- `lib/features/student/complaints/complaints.dart` — Barrel file

### Tests
- `test/complaint_test.dart` — 19 tests for Complaint, ComplaintCategory, ComplaintHistory models, extensions, parse functions

### Updated Files
- `lib/core/constants/complaint_status.dart` — Added top-level `parseComplaintStatus` function
- `lib/core/constants/complaint_priority.dart` — Added top-level `parseComplaintPriority` and `complaintPriorityFromIndex` functions
- `lib/app/router/app_router.dart` — Added student complaint routes (list, new, detail)

---

## Tests

55 tests passing:
- Auth tests (21): Profile model (6), UserRoleExtension (5), AuthState (9), AuthStatus (1)
- Complaint tests (19): Complaint model (4), ComplaintCategory (2), ComplaintHistory (2), ComplaintStatus Extension (3), ComplaintPriority Extension (2), Parse Functions (6)
- Widget tests (15): AppButton (4), StatusBadge (3), ComplaintCard (1), EmptyState (1), ErrorState (1), LoadingIndicator (2), Timeline (1), SectionHeader (1), App (1)

---

## Next Action

Awaiting user decision on **Phase 7 — Warden Module**.
