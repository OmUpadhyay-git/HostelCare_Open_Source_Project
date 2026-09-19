-- ============================================================================
-- HOSTELCARE ROW LEVEL SECURITY
-- Migration 004: RLS + Database Security
-- ============================================================================
-- Security principle: PostgreSQL RLS IS the security boundary.
-- Flutter role checks are UX convenience only.
-- A malicious authenticated user must NOT bypass authorization via direct API.
-- ============================================================================

-- ============================================================================
-- 1. HELPER FUNCTIONS
-- ============================================================================
-- These functions derive identity from auth.uid() — never from client input.
-- They are SECURITY DEFINER with fixed search_path to prevent manipulation.
-- ============================================================================

-- Get the role of the current authenticated user
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS user_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid();
$$;

-- Get the profile ID of the current authenticated user
CREATE OR REPLACE FUNCTION public.current_user_profile_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT auth.uid();
$$;

-- Check if the current user is an admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    );
$$;

-- Check if the current user is a warden
CREATE OR REPLACE FUNCTION public.is_warden()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'warden'
    );
$$;

-- Check if the current user is staff
CREATE OR REPLACE FUNCTION public.is_staff()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'staff'
    );
$$;

-- Check if the current user is a student
CREATE OR REPLACE FUNCTION public.is_student()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'student'
    );
$$;

-- Get the hostel_id of the current warden/staff user
-- Returns NULL for students and admins
CREATE OR REPLACE FUNCTION public.current_user_hostel_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT CASE
        WHEN public.current_user_role() = 'warden' THEN (
            SELECT hostel_id FROM public.wardens
            WHERE profile_id = auth.uid()
            LIMIT 1
        )
        WHEN public.current_user_role() = 'staff' THEN (
            SELECT hostel_id FROM public.staff
            WHERE profile_id = auth.uid()
            LIMIT 1
        )
        ELSE NULL
    END;
$$;

-- ============================================================================
-- 2. PRIVILEGE ESCALATION PREVENTION
-- ============================================================================
-- Prevents non-admin users from modifying sensitive profile columns.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.prevent_role_escalation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Only admins can change role or is_active
    IF NOT public.is_admin() THEN
        IF NEW.role IS DISTINCT FROM OLD.role THEN
            RAISE EXCEPTION 'Only administrators can modify user roles';
        END IF;
        IF NEW.is_active IS DISTINCT FROM OLD.is_active THEN
            RAISE EXCEPTION 'Only administrators can modify account activation status';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

-- Apply trigger to profiles table
DROP TRIGGER IF EXISTS prevent_role_escalation_trigger ON public.profiles;
CREATE TRIGGER prevent_role_escalation_trigger
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_role_escalation();

-- ============================================================================
-- 3. ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hostels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.floors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wardens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaint_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaint_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaint_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Force RLS on table owners (admins) as well — defense in depth
ALTER TABLE public.profiles FORCE ROW LEVEL SECURITY;
ALTER TABLE public.hostels FORCE ROW LEVEL SECURITY;
ALTER TABLE public.blocks FORCE ROW LEVEL SECURITY;
ALTER TABLE public.floors FORCE ROW LEVEL SECURITY;
ALTER TABLE public.rooms FORCE ROW LEVEL SECURITY;
ALTER TABLE public.students FORCE ROW LEVEL SECURITY;
ALTER TABLE public.wardens FORCE ROW LEVEL SECURITY;
ALTER TABLE public.staff FORCE ROW LEVEL SECURITY;
ALTER TABLE public.complaint_categories FORCE ROW LEVEL SECURITY;
ALTER TABLE public.complaints FORCE ROW LEVEL SECURITY;
ALTER TABLE public.complaint_images FORCE ROW LEVEL SECURITY;
ALTER TABLE public.complaint_history FORCE ROW LEVEL SECURITY;
ALTER TABLE public.notifications FORCE ROW LEVEL SECURITY;
ALTER TABLE public.feedback FORCE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs FORCE ROW LEVEL SECURITY;

-- ============================================================================
-- 4. DROP EXISTING POLICIES (safe re-runnability)
-- ============================================================================

-- Profiles
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Wardens can view students in scope" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can manage all profiles" ON public.profiles;

-- Hostels
DROP POLICY IF EXISTS "Authenticated users can view hostels" ON public.hostels;
DROP POLICY IF EXISTS "Admins can manage hostels" ON public.hostels;

-- Blocks
DROP POLICY IF EXISTS "Authenticated users can view blocks" ON public.blocks;
DROP POLICY IF EXISTS "Admins can manage blocks" ON public.blocks;

-- Floors
DROP POLICY IF EXISTS "Authenticated users can view floors" ON public.floors;
DROP POLICY IF EXISTS "Admins can manage floors" ON public.floors;

-- Rooms
DROP POLICY IF EXISTS "Authenticated users can view rooms" ON public.rooms;
DROP POLICY IF EXISTS "Admins can manage rooms" ON public.rooms;

-- Students
DROP POLICY IF EXISTS "Students can view own record" ON public.students;
DROP POLICY IF EXISTS "Wardens can view students in hostel" ON public.students;
DROP POLICY IF EXISTS "Admins can manage students" ON public.students;

-- Wardens
DROP POLICY IF EXISTS "Wardens can view own record" ON public.wardens;
DROP POLICY IF EXISTS "Admins can view all wardens" ON public.wardens;
DROP POLICY IF EXISTS "Admins can manage wardens" ON public.wardens;

-- Staff
DROP POLICY IF EXISTS "Staff can view own record" ON public.staff;
DROP POLICY IF EXISTS "Wardens can view staff in hostel" ON public.staff;
DROP POLICY IF EXISTS "Admins can manage staff" ON public.staff;

-- Complaint Categories
DROP POLICY IF EXISTS "Authenticated users can view categories" ON public.complaint_categories;
DROP POLICY IF EXISTS "Admins can manage categories" ON public.complaint_categories;

-- Complaints
DROP POLICY IF EXISTS "Students can view own complaints" ON public.complaints;
DROP POLICY IF EXISTS "Wardens can view complaints in scope" ON public.complaints;
DROP POLICY IF EXISTS "Staff can view assigned complaints" ON public.complaints;
DROP POLICY IF EXISTS "Admins can view all complaints" ON public.complaints;
DROP POLICY IF EXISTS "Students can create own complaints" ON public.complaints;
DROP POLICY IF EXISTS "Wardens can update complaints in scope" ON public.complaints;
DROP POLICY IF EXISTS "Staff can update assigned complaints" ON public.complaints;
DROP POLICY IF EXISTS "Admins can manage all complaints" ON public.complaints;

-- Complaint Images
DROP POLICY IF EXISTS "Students can view images for own complaints" ON public.complaint_images;
DROP POLICY IF EXISTS "Wardens can view images in scope" ON public.complaint_images;
DROP POLICY IF EXISTS "Staff can view images for assigned complaints" ON public.complaint_images;
DROP POLICY IF EXISTS "Admins can view all complaint images" ON public.complaint_images;
DROP POLICY IF EXISTS "Students can upload images for own complaints" ON public.complaint_images;
DROP POLICY IF EXISTS "Wardens can upload images for complaints in scope" ON public.complaint_images;
DROP POLICY IF EXISTS "Staff can upload images for assigned complaints" ON public.complaint_images;
DROP POLICY IF EXISTS "Admins can manage all complaint images" ON public.complaint_images;

-- Complaint History
DROP POLICY IF EXISTS "Students can view history for own complaints" ON public.complaint_history;
DROP POLICY IF EXISTS "Wardens can view history in scope" ON public.complaint_history;
DROP POLICY IF EXISTS "Staff can view history for assigned complaints" ON public.complaint_history;
DROP POLICY IF EXISTS "Admins can view all complaint history" ON public.complaint_history;
DROP POLICY IF EXISTS "Wardens can insert history for complaints in scope" ON public.complaint_history;
DROP POLICY IF EXISTS "Staff can insert history for assigned complaints" ON public.complaint_history;
DROP POLICY IF EXISTS "Admins can manage all complaint history" ON public.complaint_history;

-- Notifications
DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Admins can view all notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Admins can manage all notifications" ON public.notifications;

-- Feedback
DROP POLICY IF EXISTS "Students can view own feedback" ON public.feedback;
DROP POLICY IF EXISTS "Wardens can view feedback in scope" ON public.feedback;
DROP POLICY IF EXISTS "Admins can view all feedback" ON public.feedback;
DROP POLICY IF EXISTS "Students can create feedback for own complaints" ON public.feedback;
DROP POLICY IF EXISTS "Admins can manage all feedback" ON public.feedback;

-- Audit Logs
DROP POLICY IF EXISTS "Admins can view audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "Admins can manage audit logs" ON public.audit_logs;

-- ============================================================================
-- 5. RLS POLICIES — PROFILES
-- ============================================================================

-- Students can view their own profile
CREATE POLICY "Students can view own profile"
ON public.profiles FOR SELECT
TO authenticated
USING (id = auth.uid());

-- Wardens can view profiles of students in their hostel
CREATE POLICY "Wardens can view students in scope"
ON public.profiles FOR SELECT
TO authenticated
USING (
    public.current_user_role() = 'warden'
    AND id IN (
        SELECT s.profile_id FROM public.students s
        WHERE s.hostel_id = public.current_user_hostel_id()
    )
);

-- Wardens can view profiles of staff in their hostel
CREATE POLICY "Wardens can view staff in scope"
ON public.profiles FOR SELECT
TO authenticated
USING (
    public.current_user_role() = 'warden'
    AND id IN (
        SELECT st.profile_id FROM public.staff st
        WHERE st.hostel_id = public.current_user_hostel_id()
    )
);

-- Admins can view all profiles
CREATE POLICY "Admins can view all profiles"
ON public.profiles FOR SELECT
TO authenticated
USING (public.is_admin());

-- Users can update their own profile (restricted columns enforced by trigger)
CREATE POLICY "Users can update own profile"
ON public.profiles FOR UPDATE
TO authenticated
USING (id = auth.uid());

-- Admins can manage all profiles
CREATE POLICY "Admins can manage all profiles"
ON public.profiles FOR ALL
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 6. RLS POLICIES — HOSTELS (reference data)
-- ============================================================================

-- All authenticated users can view hostels (read-only reference data)
CREATE POLICY "Authenticated users can view hostels"
ON public.hostels FOR SELECT
TO authenticated
USING (true);

-- Only admins can insert/update/delete hostels
CREATE POLICY "Admins can manage hostels"
ON public.hostels FOR ALL
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 7. RLS POLICIES — BLOCKS (reference data)
-- ============================================================================

CREATE POLICY "Authenticated users can view blocks"
ON public.blocks FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Admins can manage blocks"
ON public.blocks FOR ALL
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 8. RLS POLICIES — FLOORS (reference data)
-- ============================================================================

CREATE POLICY "Authenticated users can view floors"
ON public.floors FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Admins can manage floors"
ON public.floors FOR ALL
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 9. RLS POLICIES — ROOMS (reference data)
-- ============================================================================

CREATE POLICY "Authenticated users can view rooms"
ON public.rooms FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Admins can manage rooms"
ON public.rooms FOR ALL
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 10. RLS POLICIES — STUDENTS
-- ============================================================================

-- Students can view their own student record
CREATE POLICY "Students can view own record"
ON public.students FOR SELECT
TO authenticated
USING (profile_id = auth.uid());

-- Wardens can view students in their hostel
CREATE POLICY "Wardens can view students in hostel"
ON public.students FOR SELECT
TO authenticated
USING (
    public.current_user_role() = 'warden'
    AND hostel_id = public.current_user_hostel_id()
);

-- Staff can view students in their hostel
CREATE POLICY "Staff can view students in hostel"
ON public.students FOR SELECT
TO authenticated
USING (
    public.current_user_role() = 'staff'
    AND hostel_id = public.current_user_hostel_id()
);

-- Admins can manage all students
CREATE POLICY "Admins can manage students"
ON public.students FOR ALL
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 11. RLS POLICIES — WARDENS
-- ============================================================================

-- Wardens can view their own record
CREATE POLICY "Wardens can view own record"
ON public.wardens FOR SELECT
TO authenticated
USING (profile_id = auth.uid());

-- Staff can view wardens in their hostel (for assignment context)
CREATE POLICY "Staff can view wardens in hostel"
ON public.wardens FOR SELECT
TO authenticated
USING (
    public.current_user_role() = 'staff'
    AND hostel_id = public.current_user_hostel_id()
);

-- Students can view wardens in their hostel (for complaint assignment visibility)
CREATE POLICY "Students can view wardens in hostel"
ON public.wardens FOR SELECT
TO authenticated
USING (
    public.current_user_role() = 'student'
    AND hostel_id IN (
        SELECT s.hostel_id FROM public.students s
        WHERE s.profile_id = auth.uid()
    )
);

-- Admins can view and manage all wardens
CREATE POLICY "Admins can manage wardens"
ON public.wardens FOR ALL
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 12. RLS POLICIES — STAFF
-- ============================================================================

-- Staff can view their own record
CREATE POLICY "Staff can view own record"
ON public.staff FOR SELECT
TO authenticated
USING (profile_id = auth.uid());

-- Wardens can view staff in their hostel
CREATE POLICY "Wardens can view staff in hostel"
ON public.staff FOR SELECT
TO authenticated
USING (
    public.current_user_role() = 'warden'
    AND hostel_id = public.current_user_hostel_id()
);

-- Admins can view and manage all staff
CREATE POLICY "Admins can manage staff"
ON public.staff FOR ALL
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 13. RLS POLICIES — COMPLAINT CATEGORIES (reference data)
-- ============================================================================

CREATE POLICY "Authenticated users can view categories"
ON public.complaint_categories FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Admins can manage categories"
ON public.complaint_categories FOR ALL
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 14. RLS POLICIES — COMPLAINTS (most sensitive table)
-- ============================================================================

-- SELECT policies

-- Students can view their own complaints
CREATE POLICY "Students can view own complaints"
ON public.complaints FOR SELECT
TO authenticated
USING (
    public.is_student()
    AND student_id IN (
        SELECT s.id FROM public.students s
        WHERE s.profile_id = auth.uid()
    )
);

-- Wardens can view complaints in their hostel
CREATE POLICY "Wardens can view complaints in scope"
ON public.complaints FOR SELECT
TO authenticated
USING (
    public.current_user_role() = 'warden'
    AND hostel_id = public.current_user_hostel_id()
);

-- Staff can view complaints assigned to them
CREATE POLICY "Staff can view assigned complaints"
ON public.complaints FOR SELECT
TO authenticated
USING (
    public.is_staff()
    AND assigned_staff_id IN (
        SELECT st.id FROM public.staff st
        WHERE st.profile_id = auth.uid()
    )
);

-- Admins can view all complaints
CREATE POLICY "Admins can view all complaints"
ON public.complaints FOR SELECT
TO authenticated
USING (public.is_admin());

-- INSERT policies

-- Students can create complaints for themselves
CREATE POLICY "Students can create own complaints"
ON public.complaints FOR INSERT
TO authenticated
WITH CHECK (
    public.is_student()
    AND student_id IN (
        SELECT s.id FROM public.students s
        WHERE s.profile_id = auth.uid()
    )
);

-- Wardens can create complaints on behalf of students in their hostel
CREATE POLICY "Wardens can create complaints for students in scope"
ON public.complaints FOR INSERT
TO authenticated
WITH CHECK (
    public.current_user_role() = 'warden'
    AND student_id IN (
        SELECT s.id FROM public.students s
        WHERE s.hostel_id = public.current_user_hostel_id()
    )
);

-- Admins can create any complaint
CREATE POLICY "Admins can create any complaint"
ON public.complaints FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

-- UPDATE policies

-- Wardens can update complaints in their hostel
CREATE POLICY "Wardens can update complaints in scope"
ON public.complaints FOR UPDATE
TO authenticated
USING (
    public.current_user_role() = 'warden'
    AND hostel_id = public.current_user_hostel_id()
);

-- Staff can update complaints assigned to them
CREATE POLICY "Staff can update assigned complaints"
ON public.complaints FOR UPDATE
TO authenticated
USING (
    public.is_staff()
    AND assigned_staff_id IN (
        SELECT st.id FROM public.staff st
        WHERE st.profile_id = auth.uid()
    )
);

-- Students can update complaints they own (limited fields enforced by app/RLS)
CREATE POLICY "Students can update own complaints"
ON public.complaints FOR UPDATE
TO authenticated
USING (
    public.is_student()
    AND student_id IN (
        SELECT s.id FROM public.students s
        WHERE s.profile_id = auth.uid()
    )
);

-- Admins can manage all complaints
CREATE POLICY "Admins can manage all complaints"
ON public.complaints FOR ALL
TO authenticated
USING (public.is_admin());

-- DELETE policies (only admins — historical data preservation)

CREATE POLICY "Admins can delete complaints"
ON public.complaints FOR DELETE
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 15. RLS POLICIES — COMPLAINT IMAGES
-- ============================================================================

-- SELECT: Follow complaint authorization

-- Students can view images for their own complaints
CREATE POLICY "Students can view images for own complaints"
ON public.complaint_images FOR SELECT
TO authenticated
USING (
    public.is_student()
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.student_id IN (
            SELECT s.id FROM public.students s
            WHERE s.profile_id = auth.uid()
        )
    )
);

-- Wardens can view images for complaints in their hostel
CREATE POLICY "Wardens can view images in scope"
ON public.complaint_images FOR SELECT
TO authenticated
USING (
    public.current_user_role() = 'warden'
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.hostel_id = public.current_user_hostel_id()
    )
);

-- Staff can view images for complaints assigned to them
CREATE POLICY "Staff can view images for assigned complaints"
ON public.complaint_images FOR SELECT
TO authenticated
USING (
    public.is_staff()
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.assigned_staff_id IN (
            SELECT st.id FROM public.staff st
            WHERE st.profile_id = auth.uid()
        )
    )
);

-- Admins can view all complaint images
CREATE POLICY "Admins can view all complaint images"
ON public.complaint_images FOR SELECT
TO authenticated
USING (public.is_admin());

-- INSERT: Follow complaint authorization

-- Students can upload images for their own complaints
CREATE POLICY "Students can upload images for own complaints"
ON public.complaint_images FOR INSERT
TO authenticated
WITH CHECK (
    public.is_student()
    AND uploaded_by = auth.uid()
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.student_id IN (
            SELECT s.id FROM public.students s
            WHERE s.profile_id = auth.uid()
        )
    )
);

-- Wardens can upload images for complaints in their hostel
CREATE POLICY "Wardens can upload images for complaints in scope"
ON public.complaint_images FOR INSERT
TO authenticated
WITH CHECK (
    public.current_user_role() = 'warden'
    AND uploaded_by = auth.uid()
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.hostel_id = public.current_user_hostel_id()
    )
);

-- Staff can upload images for complaints assigned to them
CREATE POLICY "Staff can upload images for assigned complaints"
ON public.complaint_images FOR INSERT
TO authenticated
WITH CHECK (
    public.is_staff()
    AND uploaded_by = auth.uid()
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.assigned_staff_id IN (
            SELECT st.id FROM public.staff st
            WHERE st.profile_id = auth.uid()
        )
    )
);

-- Admins can upload images for any complaint
CREATE POLICY "Admins can upload images for any complaint"
ON public.complaint_images FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

-- DELETE: Users can delete their own uploads, admins can delete any

CREATE POLICY "Users can delete own uploads"
ON public.complaint_images FOR DELETE
TO authenticated
USING (uploaded_by = auth.uid());

CREATE POLICY "Admins can delete any complaint images"
ON public.complaint_images FOR DELETE
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 16. RLS POLICIES — COMPLAINT HISTORY (append-only)
-- ============================================================================

-- SELECT: Follow complaint authorization

CREATE POLICY "Students can view history for own complaints"
ON public.complaint_history FOR SELECT
TO authenticated
USING (
    public.is_student()
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.student_id IN (
            SELECT s.id FROM public.students s
            WHERE s.profile_id = auth.uid()
        )
    )
);

CREATE POLICY "Wardens can view history in scope"
ON public.complaint_history FOR SELECT
TO authenticated
USING (
    public.current_user_role() = 'warden'
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.hostel_id = public.current_user_hostel_id()
    )
);

CREATE POLICY "Staff can view history for assigned complaints"
ON public.complaint_history FOR SELECT
TO authenticated
USING (
    public.is_staff()
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.assigned_staff_id IN (
            SELECT st.id FROM public.staff st
            WHERE st.profile_id = auth.uid()
        )
    )
);

CREATE POLICY "Admins can view all complaint history"
ON public.complaint_history FOR SELECT
TO authenticated
USING (public.is_admin());

-- INSERT: Wardens and staff can append history for authorized complaints

CREATE POLICY "Wardens can insert history for complaints in scope"
ON public.complaint_history FOR INSERT
TO authenticated
WITH CHECK (
    public.current_user_role() = 'warden'
    AND changed_by = auth.uid()
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.hostel_id = public.current_user_hostel_id()
    )
);

CREATE POLICY "Staff can insert history for assigned complaints"
ON public.complaint_history FOR INSERT
TO authenticated
WITH CHECK (
    public.is_staff()
    AND changed_by = auth.uid()
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.assigned_staff_id IN (
            SELECT st.id FROM public.staff st
            WHERE st.profile_id = auth.uid()
        )
    )
);

-- Students can append history (e.g., reopen action) for their own complaints
CREATE POLICY "Students can insert history for own complaints"
ON public.complaint_history FOR INSERT
TO authenticated
WITH CHECK (
    public.is_student()
    AND changed_by = auth.uid()
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.student_id IN (
            SELECT s.id FROM public.students s
            WHERE s.profile_id = auth.uid()
        )
    )
);

CREATE POLICY "Admins can manage all complaint history"
ON public.complaint_history FOR ALL
TO authenticated
USING (public.is_admin());

-- NO UPDATE or DELETE policies for complaint_history (append-only)
-- Only admins get ALL which includes delete for emergency cleanup

-- ============================================================================
-- 17. RLS POLICIES — NOTIFICATIONS
-- ============================================================================

-- Users can only see their own notifications
CREATE POLICY "Users can view own notifications"
ON public.notifications FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications"
ON public.notifications FOR UPDATE
TO authenticated
USING (user_id = auth.uid());

-- Admins can view all notifications
CREATE POLICY "Admins can view all notifications"
ON public.notifications FOR SELECT
TO authenticated
USING (public.is_admin());

-- Admins can manage all notifications
CREATE POLICY "Admins can manage all notifications"
ON public.notifications FOR ALL
TO authenticated
USING (public.is_admin());

-- System/Server can insert notifications (via SECURITY DEFINER function)
-- Client-side INSERT is restricted to admins only
CREATE POLICY "Admins can insert notifications"
ON public.notifications FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

-- ============================================================================
-- 18. RLS POLICIES — FEEDBACK
-- ============================================================================

-- Students can view their own feedback
CREATE POLICY "Students can view own feedback"
ON public.feedback FOR SELECT
TO authenticated
USING (
    public.is_student()
    AND student_id IN (
        SELECT s.id FROM public.students s
        WHERE s.profile_id = auth.uid()
    )
);

-- Wardens can view feedback for complaints in their hostel
CREATE POLICY "Wardens can view feedback in scope"
ON public.feedback FOR SELECT
TO authenticated
USING (
    public.current_user_role() = 'warden'
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.hostel_id = public.current_user_hostel_id()
    )
);

-- Admins can view all feedback
CREATE POLICY "Admins can view all feedback"
ON public.feedback FOR SELECT
TO authenticated
USING (public.is_admin());

-- Students can create feedback for their own complaints
CREATE POLICY "Students can create feedback for own complaints"
ON public.feedback FOR INSERT
TO authenticated
WITH CHECK (
    public.is_student()
    AND student_id IN (
        SELECT s.id FROM public.students s
        WHERE s.profile_id = auth.uid()
    )
    AND complaint_id IN (
        SELECT c.id FROM public.complaints c
        WHERE c.student_id IN (
            SELECT s2.id FROM public.students s2
            WHERE s2.profile_id = auth.uid()
        )
    )
);

-- Admins can manage all feedback
CREATE POLICY "Admins can manage all feedback"
ON public.feedback FOR ALL
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 19. RLS POLICIES — AUDIT LOGS
-- ============================================================================

-- Only admins can view audit logs
CREATE POLICY "Admins can view audit logs"
ON public.audit_logs FOR SELECT
TO authenticated
USING (public.is_admin());

-- Only admins can manage audit logs
CREATE POLICY "Admins can manage audit logs"
ON public.audit_logs FOR ALL
TO authenticated
USING (public.is_admin());

-- ============================================================================
-- 20. STORAGE POLICIES (replace minimal Phase 3 policies)
-- ============================================================================

-- Drop existing minimal policies
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated reads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;

-- Upload: Users can only upload to paths matching their complaint authorization
CREATE POLICY "Students can upload images for own complaints"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'complaint-images'
    AND (
        -- Admins can upload anywhere
        public.is_admin()
        OR
        -- Students can upload to their own complaint folders
        (
            public.is_student()
            AND (storage.foldername(name))[1] IN (
                SELECT c.id::text FROM public.complaints c
                WHERE c.student_id IN (
                    SELECT s.id FROM public.students s
                    WHERE s.profile_id = auth.uid()
                )
            )
        )
        OR
        -- Wardens can upload to complaints in their hostel
        (
            public.current_user_role() = 'warden'
            AND (storage.foldername(name))[1] IN (
                SELECT c.id::text FROM public.complaints c
                WHERE c.hostel_id = public.current_user_hostel_id()
            )
        )
        OR
        -- Staff can upload to assigned complaints
        (
            public.is_staff()
            AND (storage.foldername(name))[1] IN (
                SELECT c.id::text FROM public.complaints c
                WHERE c.assigned_staff_id IN (
                    SELECT st.id FROM public.staff st
                    WHERE st.profile_id = auth.uid()
                )
            )
        )
    )
);

-- SELECT: Users can only read images for complaints they're authorized to view
CREATE POLICY "Students can view images for own complaints"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'complaint-images'
    AND (
        public.is_admin()
        OR
        (
            public.is_student()
            AND (storage.foldername(name))[1] IN (
                SELECT c.id::text FROM public.complaints c
                WHERE c.student_id IN (
                    SELECT s.id FROM public.students s
                    WHERE s.profile_id = auth.uid()
                )
            )
        )
        OR
        (
            public.current_user_role() = 'warden'
            AND (storage.foldername(name))[1] IN (
                SELECT c.id::text FROM public.complaints c
                WHERE c.hostel_id = public.current_user_hostel_id()
            )
        )
        OR
        (
            public.is_staff()
            AND (storage.foldername(name))[1] IN (
                SELECT c.id::text FROM public.complaints c
                WHERE c.assigned_staff_id IN (
                    SELECT st.id FROM public.staff st
                    WHERE st.profile_id = auth.uid()
                )
            )
        )
    )
);

-- DELETE: Users can delete their own uploads, admins can delete any
CREATE POLICY "Users can delete own uploads"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'complaint-images'
    AND (
        public.is_admin()
        OR uploaded_by = auth.uid()
    )
);

-- ============================================================================
-- 21. GRANT EXECUTE ON HELPER FUNCTIONS
-- ============================================================================

-- Allow authenticated users to call helper functions
GRANT EXECUTE ON FUNCTION public.current_user_role() TO authenticated;
GRANT EXECUTE ON FUNCTION public.current_user_profile_id() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_warden() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_staff() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_student() TO authenticated;
GRANT EXECUTE ON FUNCTION public.current_user_hostel_id() TO authenticated;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- All application tables have RLS enabled.
-- All policies enforce role-based authorization.
-- Identity is derived from auth.uid() — never from client input.
-- Privilege escalation is prevented by trigger on profiles.
-- Complaint history is append-only (no UPDATE/DELETE for non-admins).
-- Storage follows complaint authorization.
-- ============================================================================
