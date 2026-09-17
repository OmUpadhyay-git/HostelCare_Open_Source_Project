# DATABASE_DESIGN.md — HostelCare
## Database Schema & Design

---

## Overview

HostelCare uses **PostgreSQL** via **Supabase** as the database backend. The schema is designed for:

- Multi-hostel support
- Role-based access control
- Audit trail for all complaint state changes
- Configurable categories with SLA
- Image storage via Supabase Storage
- In-app notifications
- Post-closure feedback

---

## Enums

### user_role
| Value | Description |
|---|---|
| `student` | Hostel resident |
| `warden` | Block/Hostel manager |
| `staff` | Maintenance personnel |
| `admin` | System administrator |

### complaint_status
| Value | Description |
|---|---|
| `pending` | Newly created, awaiting warden review |
| `accepted` | Warden accepted the complaint |
| `assigned` | Assigned to maintenance staff |
| `in_progress` | Work in progress |
| `resolved` | Work completed, awaiting verification |
| `verified` | Student verified the fix |
| `closed` | Complaint fully closed |
| `rejected` | Warden rejected (with reason) |
| `cancelled` | Student cancelled |
| `reopened` | Student reopened after verification |
| `on_hold` | Temporarily paused |

### complaint_priority
| Value | Description |
|---|---|
| `low` | Non-urgent, can wait |
| `medium` | Standard priority |
| `high` | Needs prompt attention |
| `urgent` | Immediate attention required |

### complaint_image_type
| Value | Description |
|---|---|
| `complaint` | Original complaint image |
| `progress` | Work progress image |
| `resolution` | Resolution proof image |

---

## Tables

### profiles
Links to Supabase Auth `auth.users(id)`.

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK, FK → auth.users |
| `full_name` | TEXT | NOT NULL |
| `email` | TEXT | |
| `phone` | TEXT | |
| `role` | user_role | NOT NULL, DEFAULT 'student' |
| `avatar_url` | TEXT | |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true |
| `created_at` | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() |
| `updated_at` | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() |

---

### hostels

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `name` | TEXT | NOT NULL |
| `code` | TEXT | NOT NULL, UNIQUE |
| `address` | TEXT | |
| `total_blocks` | INTEGER | DEFAULT 0 |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true |
| `created_at` | TIMESTAMPTZ | NOT NULL |
| `updated_at` | TIMESTAMPTZ | NOT NULL |

---

### blocks

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `hostel_id` | UUID | FK → hostels, NOT NULL |
| `name` | TEXT | NOT NULL |
| `code` | TEXT | NOT NULL |
| `total_floors` | INTEGER | DEFAULT 0 |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true |
| `created_at` | TIMESTAMPTZ | NOT NULL |
| `updated_at` | TIMESTAMPTZ | NOT NULL |

**Unique:** (hostel_id, code)

---

### floors

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `block_id` | UUID | FK → blocks, NOT NULL |
| `floor_number` | INTEGER | NOT NULL |
| `name` | TEXT | |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true |
| `created_at` | TIMESTAMPTZ | NOT NULL |
| `updated_at` | TIMESTAMPTZ | NOT NULL |

**Unique:** (block_id, floor_number)

---

### rooms

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `floor_id` | UUID | FK → floors, NOT NULL |
| `room_number` | TEXT | NOT NULL |
| `capacity` | INTEGER | NOT NULL, DEFAULT 1, CHECK > 0 |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true |
| `created_at` | TIMESTAMPTZ | NOT NULL |
| `updated_at` | TIMESTAMPTZ | NOT NULL |

**Unique:** (floor_id, room_number)

---

### students

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `profile_id` | UUID | FK → profiles, NOT NULL |
| `student_id` | TEXT | NOT NULL, UNIQUE |
| `hostel_id` | UUID | FK → hostels, NOT NULL |
| `block_id` | UUID | FK → blocks, NOT NULL |
| `floor_id` | UUID | FK → floors, NOT NULL |
| `room_id` | UUID | FK → rooms, NOT NULL |
| `created_at` | TIMESTAMPTZ | NOT NULL |
| `updated_at` | TIMESTAMPTZ | NOT NULL |

---

### wardens

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `profile_id` | UUID | FK → profiles, NOT NULL |
| `hostel_id` | UUID | FK → hostels, NOT NULL |
| `block_ids` | UUID[] | DEFAULT '{}' |
| `created_at` | TIMESTAMPTZ | NOT NULL |
| `updated_at` | TIMESTAMPTZ | NOT NULL |

---

### staff

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `profile_id` | UUID | FK → profiles, NOT NULL |
| `staff_id` | TEXT | NOT NULL, UNIQUE |
| `department` | TEXT | |
| `specialization` | TEXT | |
| `hostel_id` | UUID | FK → hostels, NULLABLE |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true |
| `created_at` | TIMESTAMPTZ | NOT NULL |
| `updated_at` | TIMESTAMPTZ | NOT NULL |

---

### complaint_categories

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `name` | TEXT | NOT NULL, UNIQUE |
| `description` | TEXT | |
| `sla_hours` | INTEGER | NOT NULL, DEFAULT 48, CHECK >= 0 |
| `default_priority` | complaint_priority | NOT NULL, DEFAULT 'medium' |
| `responsible_department` | TEXT | |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true |
| `created_at` | TIMESTAMPTZ | NOT NULL |
| `updated_at` | TIMESTAMPTZ | NOT NULL |

---

### complaints

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `complaint_number` | TEXT | NOT NULL, UNIQUE |
| `student_id` | UUID | FK → students, NOT NULL |
| `category_id` | UUID | FK → complaint_categories, NOT NULL |
| `assigned_warden_id` | UUID | FK → wardens, NULLABLE |
| `assigned_staff_id` | UUID | FK → staff, NULLABLE |
| `hostel_id` | UUID | FK → hostels, NOT NULL |
| `block_id` | UUID | FK → blocks, NOT NULL |
| `floor_id` | UUID | FK → floors, NOT NULL |
| `room_id` | UUID | FK → rooms, NOT NULL |
| `title` | TEXT | NOT NULL |
| `description` | TEXT | |
| `priority` | complaint_priority | NOT NULL, DEFAULT 'medium' |
| `status` | complaint_status | NOT NULL, DEFAULT 'pending' |
| `created_at` | TIMESTAMPTZ | NOT NULL |
| `updated_at` | TIMESTAMPTZ | NOT NULL |
| `accepted_at` | TIMESTAMPTZ | |
| `assigned_at` | TIMESTAMPTZ | |
| `started_at` | TIMESTAMPTZ | |
| `resolved_at` | TIMESTAMPTZ | |
| `verified_at` | TIMESTAMPTZ | |
| `closed_at` | TIMESTAMPTZ | |
| `reopened_at` | TIMESTAMPTZ | |
| `sla_deadline` | TIMESTAMPTZ | |
| `resolution_remark` | TEXT | |
| `resolution_image_path` | TEXT | |

**Complaint Number Format:** `HC-YYYY-NNNNNN` (e.g., HC-2026-000001)
Generated automatically via database sequence.

---

### complaint_images

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `complaint_id` | UUID | FK → complaints, NOT NULL, CASCADE |
| `storage_path` | TEXT | NOT NULL |
| `uploaded_by` | UUID | FK → profiles, NOT NULL |
| `image_type` | complaint_image_type | NOT NULL, DEFAULT 'complaint' |
| `created_at` | TIMESTAMPTZ | NOT NULL |

---

### complaint_history

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `complaint_id` | UUID | FK → complaints, NOT NULL |
| `changed_by` | UUID | FK → profiles, NOT NULL |
| `old_status` | complaint_status | |
| `new_status` | complaint_status | |
| `action` | TEXT | NOT NULL |
| `remark` | TEXT | |
| `created_at` | TIMESTAMPTZ | NOT NULL |

**Note:** Append-only. No UPDATE/DELETE allowed for normal roles.

---

### notifications

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `user_id` | UUID | FK → profiles, NOT NULL, CASCADE |
| `complaint_id` | UUID | FK → complaints, NULLABLE |
| `title` | TEXT | NOT NULL |
| `message` | TEXT | NOT NULL |
| `type` | TEXT | NOT NULL, DEFAULT 'info' |
| `is_read` | BOOLEAN | NOT NULL, DEFAULT false |
| `created_at` | TIMESTAMPTZ | NOT NULL |

---

### feedback

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `complaint_id` | UUID | FK → complaints, NOT NULL |
| `student_id` | UUID | FK → students, NOT NULL |
| `rating` | INTEGER | NOT NULL, CHECK 1-5 |
| `comment` | TEXT | |
| `created_at` | TIMESTAMPTZ | NOT NULL |

**Unique:** (complaint_id, student_id) — one feedback per complaint per student.

---

### audit_logs

| Column | Type | Constraints |
|---|---|---|
| `id` | UUID | PK |
| `actor_user_id` | UUID | FK → profiles, NOT NULL |
| `action` | TEXT | NOT NULL |
| `entity_type` | TEXT | NOT NULL |
| `entity_id` | UUID | NOT NULL |
| `old_data` | JSONB | |
| `new_data` | JSONB | |
| `created_at` | TIMESTAMPTZ | NOT NULL |

---

## Relationships

```
auth.users ──1:1── profiles ──1:1── students
                                    wardens
                                    staff

profiles ──1:N── audit_logs

hostels ──1:N── blocks ──1:N── floors ──1:N── rooms
                    │               │              │
                    │               │              └── students.room_id
                    │               └── students.floor_id
                    └── students.block_id
                    └── wardens.hostel_id (via block_ids)
                    └── staff.hostel_id
                    └── complaints.hostel_id

students ──1:N── complaints
wardens ──1:N── complaints (assigned)
staff ──1:N── complaints (assigned)

complaints ──1:N── complaint_images
complaints ──1:N── complaint_history
complaints ──1:N── notifications
complaints ──1:1── feedback

complaint_categories ──1:N── complaints
```

---

## Indexes

### Complaints (High Query Frequency)
- `idx_complaints_student_id` — Student's complaints
- `idx_complaints_category_id` — Filter by category
- `idx_complaints_assigned_warden_id` — Warden's queue
- `idx_complaints_assigned_staff_id` — Staff's assignments
- `idx_complaints_status` — Filter by status
- `idx_complaints_priority` — Filter by priority
- `idx_complaints_created_at` — Date range queries
- `idx_complaints_hostel_id` — Hostel-scoped queries

### Notifications
- `idx_notifications_user_id` — User's notifications
- `idx_notifications_is_read` — Unread filter
- `idx_notifications_created_at` — Date ordering

### Complaint History
- `idx_complaint_history_complaint_id` — Complaint timeline

### Audit Logs
- `idx_audit_logs_actor_user_id` — Actor filter
- `idx_audit_logs_entity_type` — Entity type filter
- `idx_audit_logs_entity_id` — Entity lookup
- `idx_audit_logs_created_at` — Date range queries

---

## Storage

### Bucket: complaint-images
- **Public:** false (private)
- **File Size Limit:** 10MB
- **Allowed MIME Types:** image/jpeg, image/png, image/webp
- **Path Structure:** `{complaint_id}/{image_type}/{filename}`

---

## Functions & Triggers

### update_updated_at_column()
Automatically updates `updated_at` on row update.

### generate_complaint_number()
Generates unique complaint numbers: `HC-YYYY-NNNNNN`
Uses PostgreSQL sequence for guaranteed uniqueness.

---

## Seed Data

### Initial Complaint Categories
1. Electrical (48h SLA, high priority)
2. Plumbing (48h SLA, high priority)
3. Water (24h SLA, high priority)
4. Cleaning (24h SLA, medium priority)
5. Furniture (72h SLA, medium priority)
6. Room Maintenance (72h SLA, medium priority)
7. Wi-Fi / Internet (48h SLA, medium priority)
8. Mess / Food (12h SLA, high priority)
9. Laundry (48h SLA, low priority)
10. Security (24h SLA, urgent priority)
11. Air Conditioning (48h SLA, medium priority)
12. Fan (48h SLA, medium priority)
13. Light (48h SLA, low priority)
14. Bathroom (24h SLA, high priority)
15. Other (72h SLA, medium priority)

---

## RLS Preparation

The schema is designed for Row Level Security:

- **Students:** Own complaints, own notifications, own feedback
- **Wardens:** Complaints within authorized hostel/block
- **Staff:** Assigned complaints only
- **Admin:** Full access to all data

RLS policies will be implemented in Phase 5.

---

## Migration Files

| File | Description |
|---|---|
| `001_initial_schema.sql` | All tables, enums, functions, indexes |
| `002_seed_data.sql` | Initial complaint categories |
| `003_storage.sql` | Storage bucket and policies |

---

## Notes

- All timestamps use `TIMESTAMPTZ` (timezone-aware)
- UUIDs are used as primary keys for all tables
- Soft-delete pattern (`is_active`) used for hostels, blocks, floors, rooms, staff
- No `ON DELETE CASCADE` on complaint-related tables (historical data preserved)
- Complaint numbers are generated server-side for guaranteed uniqueness
