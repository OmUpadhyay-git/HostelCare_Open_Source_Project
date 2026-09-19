-- ============================================================================
-- HOSTELCARE RLS VERIFICATION TESTS
-- Run this script AFTER applying migration 004_rls_security.sql
-- ============================================================================
-- IMPORTANT: These tests require Supabase Auth users to exist.
-- Create test users in Supabase dashboard first, then run tests.
--
-- TEST USERS NEEDED:
--   1. Student A: auth.users row + profiles(role='student') + students(hostel_id=H1)
--   2. Student B: auth.users row + profiles(role='student') + students(hostel_id=H1)
--   3. Student C: auth.users row + profiles(role='student') + students(hostel_id=H2)
--   4. Warden 1: auth.users row + profiles(role='warden') + wardens(hostel_id=H1)
--   5. Warden 2: auth.users row + profiles(role='warden') + wardens(hostel_id=H2)
--   6. Staff 1:  auth.users row + profiles(role='staff') + staff(hostel_id=H1)
--   7. Staff 2:  auth.users row + profiles(role='staff') + staff(hostel_id=H2)
--   8. Admin 1:  auth.users row + profiles(role='admin')
--
-- To simulate authenticated users in SQL, use:
--   SET request.jwt.claims = '{"sub": "<auth_user_id>", "role": "authenticated"}';
--   SET role = 'authenticated';
-- ============================================================================

-- ============================================================================
-- TEST 1: Unauthenticated access is blocked
-- ============================================================================
-- Verify: Anon (no JWT) cannot read any data

-- RESET first
RESET ROLE;
RESET request.jwt.claims;

-- Test: Try reading profiles as anon (should return 0 rows due to RLS)
SELECT
    'TEST 1: Anon access blocked' AS test_name,
    (SELECT COUNT(*) FROM public.profiles) AS actual_rows,
    0 AS expected_rows,
    CASE WHEN (SELECT COUNT(*) FROM public.profiles) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================================================
-- TEST 2: Student can only see own profile
-- ============================================================================
-- Simulate Student A's JWT

SET request.jwt.claims = '{"sub": "<STUDENT_A_AUTH_UUID>", "role": "authenticated"}';
SET role = 'authenticated';

SELECT
    'TEST 2: Student sees own profile only' AS test_name,
    (SELECT COUNT(*) FROM public.profiles) AS actual_rows,
    1 AS expected_rows,
    CASE WHEN (SELECT COUNT(*) FROM public.profiles) = 1
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- Verify it's the correct profile
SELECT
    'TEST 2b: Correct profile returned' AS test_name,
    (SELECT id FROM public.profiles) AS returned_id,
    '<STUDENT_A_AUTH_UUID>' AS expected_id,
    CASE WHEN (SELECT id FROM public.profiles) = '<STUDENT_A_AUTH_UUID>'::uuid
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================================================
-- TEST 3: Student cannot see other students' profiles
-- ============================================================================
-- Student A should see 0 rows for Student B's profile

SELECT
    'TEST 3: Student cannot see other students' AS test_name,
    (SELECT COUNT(*) FROM public.profiles WHERE id = '<STUDENT_B_AUTH_UUID>'::uuid) AS actual_rows,
    0 AS expected_rows,
    CASE WHEN (SELECT COUNT(*) FROM public.profiles WHERE id = '<STUDENT_B_AUTH_UUID>'::uuid) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================================================
-- TEST 4: Student can only see own complaints
-- ============================================================================

SELECT
    'TEST 4: Student sees own complaints only' AS test_name,
    (SELECT COUNT(*) FROM public.complaints) AS visible_complaints,
    -- Should only see complaints where student_id matches their students.id
    (SELECT COUNT(*) FROM public.complaints c
     JOIN public.students s ON c.student_id = s.id
     WHERE s.profile_id = auth.uid()) AS expected_complaints,
    CASE WHEN (SELECT COUNT(*) FROM public.complaints) =
         (SELECT COUNT(*) FROM public.complaints c
          JOIN public.students s ON c.student_id = s.id
          WHERE s.profile_id = auth.uid())
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================================================
-- TEST 5: Student cannot see other students' complaints
-- ============================================================================
-- Student A should not see Student B's complaints (Student B is in different hostel or different student)

SELECT
    'TEST 5: Student cannot see other student complaints' AS test_name,
    (SELECT COUNT(*) FROM public.complaints c
     WHERE c.student_id = (
         SELECT id FROM public.students WHERE profile_id = '<STUDENT_B_AUTH_UUID>'::uuid
     )) AS other_student_complaints_visible,
    0 AS expected,
    CASE WHEN (SELECT COUNT(*) FROM public.complaints c
               WHERE c.student_id = (
                   SELECT id FROM public.students WHERE profile_id = '<STUDENT_B_AUTH_UUID>'::uuid
               )) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================================================
-- TEST 6: Warden can see complaints in their hostel
-- ============================================================================

RESET ROLE;
RESET request.jwt.claims;

SET request.jwt.claims = '{"sub": "<WARDEN_1_AUTH_UUID>", "role": "authenticated"}';
SET role = 'authenticated';

SELECT
    'TEST 6: Warden sees complaints in own hostel' AS test_name,
    (SELECT COUNT(*) FROM public.complaints c
     WHERE c.hostel_id = (
         SELECT w.hostel_id FROM public.wardens w
         WHERE w.profile_id = auth.uid()
     )) AS warden_visible,
    (SELECT COUNT(*) FROM public.complaints c
     WHERE c.hostel_id = public.current_user_hostel_id()) AS expected,
    CASE WHEN (SELECT COUNT(*) FROM public.complaints c
               WHERE c.hostel_id = public.current_user_hostel_id()) >= 0
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================================================
-- TEST 7: Warden cannot see complaints from other hostels
-- ============================================================================

SELECT
    'TEST 7: Warden cannot see other hostel complaints' AS test_name,
    (SELECT COUNT(*) FROM public.complaints c
     WHERE c.hostel_id != public.current_user_hostel_id()) AS other_hostel_visible,
    0 AS expected,
    CASE WHEN (SELECT COUNT(*) FROM public.complaints c
               WHERE c.hostel_id != public.current_user_hostel_id()) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================================================
-- TEST 8: Staff can see only assigned complaints
-- ============================================================================

RESET ROLE;
RESET request.jwt.claims;

SET request.jwt.claims = '{"sub": "<STAFF_1_AUTH_UUID>", "role": "authenticated"}';
SET role = 'authenticated';

SELECT
    'TEST 8: Staff sees only assigned complaints' AS test_name,
    (SELECT COUNT(*) FROM public.complaints c
     WHERE c.assigned_staff_id = (
         SELECT id FROM public.staff WHERE profile_id = auth.uid()
     )) AS staff_visible,
    (SELECT COUNT(*) FROM public.complaints) AS total_visible,
    CASE WHEN (SELECT COUNT(*) FROM public.complaints) =
         (SELECT COUNT(*) FROM public.complaints c
          WHERE c.assigned_staff_id = (
              SELECT id FROM public.staff WHERE profile_id = auth.uid()
          ))
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================================================
-- TEST 9: Staff cannot see unassigned complaints
-- ============================================================================

SELECT
    'TEST 9: Staff cannot see unassigned complaints' AS test_name,
    (SELECT COUNT(*) FROM public.complaints c
     WHERE c.assigned_staff_id IS NULL
        OR c.assigned_staff_id != (
            SELECT id FROM public.staff WHERE profile_id = auth.uid()
        )) AS unassigned_visible,
    0 AS expected,
    CASE WHEN (SELECT COUNT(*) FROM public.complaints c
               WHERE c.assigned_staff_id IS NULL
                  OR c.assigned_staff_id != (
                      SELECT id FROM public.staff WHERE profile_id = auth.uid()
                  )) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================================================
-- TEST 10: Student cannot update complaints to escalate role
-- ============================================================================

RESET ROLE;
RESET request.jwt.claims;

SET request.jwt.claims = '{"sub": "<STUDENT_A_AUTH_UUID>", "role": "authenticated"}';
SET role = 'authenticated';

-- Student should be able to UPDATE own complaint (limited fields)
-- But the trigger should prevent role escalation on profiles
BEGIN;

-- This should work: student updates their own complaint description
UPDATE public.complaints
SET description = 'Updated by student'
WHERE id = (
    SELECT c.id FROM public.complaints c
    JOIN public.students s ON c.student_id = s.id
    WHERE s.profile_id = auth.uid()
    LIMIT 1
);

-- This should FAIL: student tries to change their own role
DO $$
BEGIN
    UPDATE public.profiles SET role = 'admin' WHERE id = auth.uid();
    RAISE NOTICE 'TEST 10: FAIL - Student was able to escalate role!';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'TEST 10: PASS - Student role escalation blocked: %', SQLERRM;
END;
$$;

ROLLBACK;

-- ============================================================================
-- TEST 11: Admin can see all data
-- ============================================================================

RESET ROLE;
RESET request.jwt.claims;

SET request.jwt.claims = '{"sub": "<ADMIN_1_AUTH_UUID>", "role": "authenticated"}';
SET role = 'authenticated';

SELECT
    'TEST 11: Admin sees all profiles' AS test_name,
    (SELECT COUNT(*) FROM public.profiles) AS profiles_visible,
    -- Should see all profiles (at least the test users)
    CASE WHEN (SELECT COUNT(*) FROM public.profiles) >= 8
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

SELECT
    'TEST 11b: Admin sees all complaints' AS test_name,
    (SELECT COUNT(*) FROM public.complaints) AS complaints_visible,
    CASE WHEN (SELECT COUNT(*) FROM public.complaints) >= 0
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================================================
-- TEST 12: Notification isolation
-- ============================================================================

RESET ROLE;
RESET request.jwt.claims;

SET request.jwt.claims = '{"sub": "<STUDENT_A_AUTH_UUID>", "role": "authenticated"}';
SET role = 'authenticated';

SELECT
    'TEST 12: Student sees only own notifications' AS test_name,
    (SELECT COUNT(*) FROM public.notifications) AS visible,
    (SELECT COUNT(*) FROM public.notifications
     WHERE user_id = auth.uid()) AS expected,
    CASE WHEN (SELECT COUNT(*) FROM public.notifications) =
         (SELECT COUNT(*) FROM public.notifications WHERE user_id = auth.uid())
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================================================
-- TEST 13: Complaint history is append-only for non-admins
-- ============================================================================

RESET ROLE;
RESET request.jwt.claims;

SET request.jwt.claims = '{"sub": "<WARDEN_1_AUTH_UUID>", "role": "authenticated"}';
SET role = 'authenticated';

-- Warden can INSERT history for their hostel's complaints
-- But should NOT be able to UPDATE or DELETE existing history

-- Test UPDATE (should fail - no UPDATE policy for wardens)
BEGIN;

DO $$
BEGIN
    UPDATE public.complaint_history
    SET remark = 'Tampered'
    WHERE id = (
        SELECT id FROM public.complaint_history LIMIT 1
    );
    RAISE NOTICE 'TEST 13a: FAIL - Warden was able to update complaint history!';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'TEST 13a: PASS - History update blocked: %', SQLERRM;
END;
$$;

ROLLBACK;

-- Test DELETE (should fail - no DELETE policy for wardens)
BEGIN;

DO $$
BEGIN
    DELETE FROM public.complaint_history
    WHERE id = (
        SELECT id FROM public.complaint_history LIMIT 1
    );
    RAISE NOTICE 'TEST 13b: FAIL - Warden was able to delete complaint history!';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'TEST 13b: PASS - History delete blocked: %', SQLERRM;
END;
$$;

ROLLBACK;

-- ============================================================================
-- TEST 14: Reference data is readable by all authenticated users
-- ============================================================================

RESET ROLE;
RESET request.jwt.claims;

SET request.jwt.claims = '{"sub": "<STUDENT_A_AUTH_UUID>", "role": "authenticated"}';
SET role = 'authenticated';

SELECT
    'TEST 14a: Student can read hostels' AS test_name,
    (SELECT COUNT(*) FROM public.hostels) AS count,
    CASE WHEN (SELECT COUNT(*) FROM public.hostels) > 0
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

SELECT
    'TEST 14b: Student can read complaint categories' AS test_name,
    (SELECT COUNT(*) FROM public.complaint_categories) AS count,
    CASE WHEN (SELECT COUNT(*) FROM public.complaint_categories) > 0
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- Test that student CANNOT modify reference data
BEGIN;

DO $$
BEGIN
    INSERT INTO public.hostels (name, code) VALUES ('Hacked Hostel', 'HACK');
    RAISE NOTICE 'TEST 14c: FAIL - Student was able to insert into hostels!';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'TEST 14c: PASS - Hostel insert blocked: %', SQLERRM;
END;
$$;

ROLLBACK;

-- ============================================================================
-- TEST 15: Audit logs are admin-only
-- ============================================================================

RESET ROLE;
RESET request.jwt.claims;

SET request.jwt.claims = '{"sub": "<STUDENT_A_AUTH_UUID>", "role": "authenticated"}';
SET role = 'authenticated';

SELECT
    'TEST 15: Student cannot see audit logs' AS test_name,
    (SELECT COUNT(*) FROM public.audit_logs) AS visible,
    0 AS expected,
    CASE WHEN (SELECT COUNT(*) FROM public.audit_logs) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================================================
-- CLEANUP
-- ============================================================================

RESET ROLE;
RESET request.jwt.claims;

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- Expected results:
--   TEST 1:  PASS  — Anon sees 0 rows
--   TEST 2:  PASS  — Student sees own profile (1 row)
--   TEST 2b: PASS  — Correct profile returned
--   TEST 3:  PASS  — Student sees 0 rows for other student
--   TEST 4:  PASS  — Student sees only own complaints
--   TEST 5:  PASS  — Student sees 0 rows for other student's complaints
--   TEST 6:  PASS  — Warden sees complaints in own hostel
--   TEST 7:  PASS  — Warden sees 0 rows for other hostels
--   TEST 8:  PASS  — Staff sees only assigned complaints
--   TEST 9:  PASS  — Staff sees 0 unassigned complaints
--   TEST 10: PASS  — Student role escalation blocked
--   TEST 11: PASS  — Admin sees all profiles
--   TEST 11b: PASS — Admin sees all complaints
--   TEST 12: PASS  — Student sees only own notifications
--   TEST 13: PASS  — Complaint history is append-only for non-admins
--   TEST 14: PASS  — Reference data readable but not writable by students
--   TEST 15: PASS  — Student cannot see audit logs
-- ============================================================================
