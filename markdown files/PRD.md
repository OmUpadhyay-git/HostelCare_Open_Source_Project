# PRD.md — HostelCare
## Project Requirements Document

---

## 1. Overview

**HostelCare** is a production-quality, cross-platform mobile application (Android + iOS) for real-world hostel complaint and maintenance management. It replaces manual complaint registers and informal WhatsApp-based reporting with a structured, auditable digital workflow.

This is **not** a demo/college CRUD project. It must be secure, scalable, maintainable, and reliable under real operating conditions (multiple hostels, unreliable networks, real users).

---

## 2. Problem Statement

Hostels currently rely on manual registers or ad-hoc messaging apps to report and track maintenance issues. This causes:

- Lost or forgotten complaints
- No accountability or audit trail
- No visibility into resolution time or SLA compliance
- No way for students to verify a fix actually happened
- No data for administrators to identify recurring problems

---

## 3. Target Users

| Role | Description |
|---|---|
| **Student** | Lives in a hostel room; reports problems and tracks their resolution. |
| **Warden** | Manages complaints for their authorized hostel/block; assigns work. |
| **Maintenance Staff** | Executes assigned repair/maintenance work. |
| **Admin** | Configures the system, manages users/hostels/categories, views system-wide analytics. |

---

## 4. Goals

- Give students a fast, simple way to report hostel problems with evidence (photos).
- Give wardens a clear operational queue with authority scoped to their hostel/block.
- Give staff a focused task list with nothing beyond what they're assigned.
- Give admins full configurability without code changes (hostels, categories, SLA, priority rules).
- Guarantee every state change is recorded, auditable, and cannot be bypassed via the UI.
- Guarantee data isolation — no user can access another user's private data.

## 5. Non-Goals (for MVP)

- Push notifications (added after in-app notifications are stable)
- Advanced analytics/reporting dashboards
- Escalation automation beyond basic SLA breach detection
- Multi-language support
- Web application (mobile-first only)

---

## 6. Core Feature Set

### 6.1 Student
- Login / session management
- View profile (name, student ID, hostel/block/room — read-only, admin-controlled)
- Raise complaint (category, title, description, priority suggestion, images)
- Track complaint status and history
- Receive notifications
- Verify or reject a resolution
- Reopen a complaint with a reason
- Cancel an eligible complaint
- Submit feedback (1–5 rating + comment) after closure

### 6.2 Warden
- Login
- View complaints scoped to authorized hostel(s)/block(s)
- Accept / reject (with reason) a complaint
- Assign complaint to staff
- Add remarks, update status through valid transitions
- Upload resolution evidence
- Resolve complaints; handle reopened complaints
- View operational statistics for their scope

### 6.3 Maintenance Staff
- Login
- View only complaints assigned to them
- Accept assignment, start work
- Add progress remarks and images
- Mark work complete / submit resolution
- No administrative permissions of any kind

### 6.4 Admin
- Manage students, wardens, staff, hostels, blocks, rooms, categories, SLA/priority config
- View all complaints, history, overdue items, feedback, reports, audit logs
- Deactivate (never hard-delete) users with historical data
- View system-wide analytics

---

## 7. Complaint Lifecycle (Functional Requirement)

```
PENDING → ACCEPTED → ASSIGNED → IN_PROGRESS → RESOLVED → VERIFIED → CLOSED
                                                    │
                                                    ├─ Student says "not fixed" → REOPENED → (back into workflow)
PENDING → REJECTED (by warden, with reason)
Any eligible state → CANCELLED (by student, before work starts)
Any active state → ON_HOLD → resumes
```

All transitions are role- and state-validated on the backend. Invalid transitions must be rejected regardless of what the client sends.

---

## 8. Multi-Hostel Requirement

The system must support multiple hostels from day one:

```
Hostel → Block → Floor → Room → Student
```

Nothing (hostel names, blocks, rooms, categories, SLA values) may be hardcoded in the app — all of it is admin-configurable data.

---

## 9. Complaint Categories (initial seed set)

Electrical, Plumbing, Water, Cleaning, Furniture, Room Maintenance, Wi-Fi/Internet, Mess/Food, Laundry, Security, Air Conditioning, Fan, Light, Bathroom, Other.

Each category has: name, description, active flag, SLA hours, default priority, responsible staff type.

---

## 10. Priority & SLA

- Priority levels: LOW, MEDIUM, HIGH, URGENT.
- Students may *suggest* a priority; the system/warden determines the operational priority.
- Every category carries a configurable SLA (hours). Complaints display "Within SLA" or "Overdue" — never a hardcoded value.
- Escalation: SLA breach → Level 1 (warden notified) → after configurable delay → Level 2 (admin notified).

---

## 11. Non-Functional Requirements

| Requirement | Detail |
|---|---|
| **Security** | Supabase Auth + Row Level Security on every sensitive table. UI restrictions are never treated as security. |
| **Data isolation** | Students cannot access other students' complaints, notifications, phone numbers, or feedback. Wardens/staff scoped strictly to their authorization. |
| **Reliability** | No silent data loss on network failure during complaint submission; retry mechanisms; no duplicate complaints from double-taps. |
| **Scalability** | Server-side pagination and filtering — never bulk-download-then-filter-locally. |
| **Auditability** | Every significant state change recorded in an append-only history table (who, what, when, old/new status, remark). |
| **Configurability** | Hostels, blocks, rooms, categories, SLA, priority rules all admin-managed, not hardcoded. |
| **Honesty of data** | Dashboards never show fabricated statistics. Zero data → "No complaint data available." |

---

## 12. Success Criteria (MVP)

A student can log in, raise a complaint with a photo, and track it through to a warden accepting it, assigning a staff member, the staff resolving it, and the student verifying and closing it — with every step reflected in complaint history — without any step relying on client-side trust for authorization.

---

## 13. Out-of-Scope Risks to Flag Early

- Apple App Store distribution is not free — budget/time for a developer account.
- Free-tier Supabase limits (storage, DB size, auth users) must be checked before relying on them long-term.
- Push notification service choice must be revisited once in-app notifications are stable (Phase 12).
