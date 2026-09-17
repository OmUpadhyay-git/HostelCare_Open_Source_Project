# Architecture.md — HostelCare

---

## 1. High-Level System Architecture

```
Flutter App (Android + iOS)
        │
        ▼
  Supabase Auth   ──────┐
        │               │
        ▼               ▼
  PostgreSQL  ◄──  Row Level Security (RLS)
        │
        ▼
  Supabase Storage (images)
```

- **No custom backend server.** Supabase (Auth + PostgreSQL + RLS + Storage + Edge Functions where genuinely required) is the entire backend.
- A separate Node.js/Express backend is only introduced if a future requirement cannot be safely implemented with Supabase/database functions/edge functions.
- Business rules that must never be bypassable (status transitions, authorization) are enforced in PostgreSQL (RLS policies + constraints + functions/triggers), not only in Flutter.

---

## 2. Technical Stack

| Layer | Technology |
|---|---|
| Client | Flutter (Android + iOS) |
| State management | Riverpod |
| Navigation | GoRouter with protected/role-based routes |
| Backend | Supabase (Auth, PostgreSQL, Storage, RLS, Edge Functions if needed) |
| Local secure storage | `flutter_secure_storage` (never `SharedPreferences` for tokens) |
| Notifications (in-app) | Supabase table + realtime subscription |
| Notifications (push) | Added post-MVP; free-tier provider (e.g. Firebase Cloud Messaging) evaluated in Phase 12 |
| Image handling | Supabase Storage, compressed client-side before upload |

---

## 3. Flutter Folder Structure

```
lib/
  app/
    router/          # GoRouter config, route guards
    theme/            # Material 3 theme, design tokens
    config/           # Environment config (dev/prod)

  core/
    constants/
    errors/            # Centralized error types + mapping to user messages
    utils/
    validators/

  models/              # Data models (Complaint, User, Hostel, Category, etc.)

  repositories/         # Supabase query layer — one repository per entity
  services/              # Auth service, storage service, notification service
  providers/              # Riverpod providers (business/data state)

  features/
    auth/
    student/
      dashboard/
      complaints/
      notifications/
      profile/
    warden/
      dashboard/
      complaints/
      students/
      notifications/
      profile/
    staff/
      dashboard/
      assignments/
      complaints/
      notifications/
      profile/
    admin/
      dashboard/
      students/
      wardens/
      staff/
      hostels/
      blocks/
      rooms/
      categories/
      complaints/
      reports/
      settings/

  shared/
    widgets/
    components/
```

**Rule:** widgets stay thin. Database/business logic lives in repositories and providers, never directly inside widget build methods.

---

## 4. Data Access Strategy

- All reads/writes go through a **repository layer** — no raw Supabase calls scattered across UI code.
- Repositories return typed models, never raw JSON, to the UI layer.
- Riverpod providers wrap repositories and expose UI-consumable state (loading/data/error).
- **Pagination is mandatory** for any list endpoint (complaints, users, notifications). No "fetch all, filter client-side."
- Filtering (status, category, priority, hostel, block, date range, SLA status) is done via Supabase queries — server-side.

---

## 5. Database Architecture (Entity Overview)

Core tables:

- `users` (role: student/warden/staff/admin; `is_active`; `last_login_at`)
- `hostels`, `blocks`, `floors`, `rooms`
- `complaint_categories` (SLA hours, default priority, responsible staff type)
- `complaints` (student_id, category_id, hostel/block/floor/room, priority, status, assigned_warden_id, assigned_staff_id, complaint_number, created_at, sla_deadline, resolved_at)
- `complaint_history` (append-only audit trail — action, old_status, new_status, performed_by, role, remark, timestamp)
- `complaint_images` (storage_path, metadata, uploaded_by, created_at — never binary in Postgres)
- `notifications` (user_id, title, message, type, related_complaint_id, is_read, created_at)
- `feedback` (complaint_id, student_id, rating, comment — one per complaint)
- `admin_audit_log` (who, what, target, old_value, new_value, timestamp)
- `device_tokens` (for push, post-MVP; supports multiple devices per user)

Key constraints:
- UUID primary keys
- Foreign keys with appropriate `ON DELETE` behavior (never cascading deletes on historical data — use `is_active` soft-deletes instead)
- `NOT NULL` and `CHECK` constraints for status/priority enums
- Unique constraint on `complaint_number` and on `(complaint_id)` for feedback
- Indexes on: `complaints.status`, `complaints.student_id`, `complaints.assigned_warden_id`, `complaints.assigned_staff_id`, `complaints.category_id`, `complaints.created_at`, `complaints.priority`, `notifications.user_id`, `notifications.is_read`

---

## 6. Row Level Security Model (Summary)

| Table | Student | Warden | Staff | Admin |
|---|---|---|---|---|
| `complaints` | Own rows only | Rows within authorized hostel/block | Rows assigned to them only | All rows |
| `complaint_history` | Read own complaint's history only | Read/append within scope | Read/append for assigned complaints | Full access |
| `notifications` | Own rows only | Own rows only | Own rows only | Full access (read) |
| `feedback` | Create/read own | Read within scope | No access | Full access |
| `users` | Read own profile only | Read limited fields of students in scope | No access | Full access |
| `hostels/blocks/rooms/categories` | Read (active only) | Read (active only) | Read (active only) | Full manage access |
| `admin_audit_log` | No access | No access | No access | Full access |

Every policy is enforced in PostgreSQL. The Flutter app hiding a screen is a UX convenience only — it is never the security boundary.

---

## 7. Navigation Architecture

- GoRouter with a top-level redirect guard checking auth state + role on every navigation.
- Route groups: `/auth/*`, `/student/*`, `/warden/*`, `/staff/*`, `/admin/*`.
- Unauthorized access attempts are redirected, not just visually hidden — the underlying data call would also fail RLS as a second layer of defense.

---

## 8. Error & Network Handling Architecture

- Centralized error mapper: Supabase/Postgres errors → user-friendly messages. Raw errors, stack traces, and internal details are never shown.
- All mutating actions (e.g. submit complaint) are wrapped with: disable-while-in-flight, retry-on-failure, and preserve user input on failure (no silent data loss).
- Idempotency: duplicate-tap protection on complaint submission (client-side debounce + a server-side duplicate-detection check within a short time window).

---

## 9. Notification Architecture

- **In-app (MVP):** `notifications` table + Supabase Realtime subscription per user, filtered by RLS.
- **Push (post-MVP):** device token registration table supporting multiple devices/user, token refresh handling, and graceful failure — a push failure must never block complaint creation or any other core action.

---

## 10. Environments

- `dev` and `prod` Supabase projects, selected via environment variables/config, never hardcoded.
- No secrets (service role key, DB passwords) committed to Git — `.env` files gitignored.
