-- ============================================================================
-- HOSTELCARE DATABASE SCHEMA
-- Migration 007: Warden Complaint Action RPC Functions
-- ============================================================================
-- All functions use SECURITY DEFINER + SET search_path = public
-- Identity derived from auth.uid() — never from client-supplied values.
-- ============================================================================

-- ============================================================================
-- accept_complaint
-- Called by warden when status = 'pending'
-- Sets status to 'accepted' and records accepted_at timestamp.
-- Validates: authenticated user is warden, complaint belongs to warden's hostel.
-- ============================================================================
CREATE OR REPLACE FUNCTION accept_complaint(
    p_complaint_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_profile_id UUID := auth.uid();
    v_current_status complaint_status;
    v_complaint_hostel_id UUID;
    v_warden_hostel_id UUID;
BEGIN
    -- Get current status and hostel
    SELECT status, hostel_id
      INTO v_current_status, v_complaint_hostel_id
      FROM complaints
     WHERE id = p_complaint_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Complaint not found';
    END IF;

    -- Verify the caller is a warden
    IF NOT public.is_warden() THEN
        RAISE EXCEPTION 'Only wardens can accept complaints';
    END IF;

    -- Verify the warden's hostel matches the complaint's hostel
    v_warden_hostel_id := public.current_user_hostel_id();
    IF v_complaint_hostel_id <> v_warden_hostel_id THEN
        RAISE EXCEPTION 'Complaint does not belong to your authorized hostel';
    END IF;

    -- Must be in pending status
    IF v_current_status <> 'pending' THEN
        RAISE EXCEPTION 'Only pending complaints can be accepted (current status: %)', v_current_status;
    END IF;

    -- Accept the complaint
    UPDATE complaints
       SET status = 'accepted',
           accepted_at = NOW(),
           updated_at = NOW()
     WHERE id = p_complaint_id;

    INSERT INTO complaint_history (
        complaint_id, previous_status, new_status, changed_by, remarks
    ) VALUES (
        p_complaint_id, v_current_status, 'accepted', v_profile_id,
        'Complaint accepted by warden'
    );
END;
$$;

-- ============================================================================
-- reject_complaint
-- Called by warden when status = 'pending'
-- Sets status to 'rejected' and records the reason.
-- Validates: authenticated user is warden, complaint belongs to warden's hostel.
-- ============================================================================
CREATE OR REPLACE FUNCTION reject_complaint(
    p_complaint_id UUID,
    p_reason TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_profile_id UUID := auth.uid();
    v_current_status complaint_status;
    v_complaint_hostel_id UUID;
    v_warden_hostel_id UUID;
BEGIN
    SELECT status, hostel_id
      INTO v_current_status, v_complaint_hostel_id
      FROM complaints
     WHERE id = p_complaint_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Complaint not found';
    END IF;

    IF NOT public.is_warden() THEN
        RAISE EXCEPTION 'Only wardens can reject complaints';
    END IF;

    v_warden_hostel_id := public.current_user_hostel_id();
    IF v_complaint_hostel_id <> v_warden_hostel_id THEN
        RAISE EXCEPTION 'Complaint does not belong to your authorized hostel';
    END IF;

    IF v_current_status <> 'pending' THEN
        RAISE EXCEPTION 'Only pending complaints can be rejected (current status: %)', v_current_status;
    END IF;

    IF p_reason IS NULL OR TRIM(p_reason) = '' THEN
        RAISE EXCEPTION 'Rejection reason is required';
    END IF;

    UPDATE complaints
       SET status = 'rejected',
           resolution_remark = p_reason,
           updated_at = NOW()
     WHERE id = p_complaint_id;

    INSERT INTO complaint_history (
        complaint_id, previous_status, new_status, changed_by, remarks
    ) VALUES (
        p_complaint_id, v_current_status, 'rejected', v_profile_id,
        'Rejected: ' || p_reason
    );
END;
$$;

-- ============================================================================
-- assign_complaint
-- Called by warden when status = 'accepted'
-- Sets status to 'assigned' and records the staff assignment.
-- Validates: authenticated user is warden, complaint in warden's hostel,
--           staff member is active and belongs to the same hostel.
-- ============================================================================
CREATE OR REPLACE FUNCTION assign_complaint(
    p_complaint_id UUID,
    p_staff_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_profile_id UUID := auth.uid();
    v_current_status complaint_status;
    v_complaint_hostel_id UUID;
    v_warden_hostel_id UUID;
    v_staff_active BOOLEAN;
    v_staff_hostel_id UUID;
BEGIN
    SELECT status, hostel_id
      INTO v_current_status, v_complaint_hostel_id
      FROM complaints
     WHERE id = p_complaint_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Complaint not found';
    END IF;

    IF NOT public.is_warden() THEN
        RAISE EXCEPTION 'Only wardens can assign complaints';
    END IF;

    v_warden_hostel_id := public.current_user_hostel_id();
    IF v_complaint_hostel_id <> v_warden_hostel_id THEN
        RAISE EXCEPTION 'Complaint does not belong to your authorized hostel';
    END IF;

    IF v_current_status <> 'accepted' THEN
        RAISE EXCEPTION 'Only accepted complaints can be assigned (current status: %)', v_current_status;
    END IF;

    -- Verify staff exists, is active, and belongs to the same hostel
    SELECT is_active, hostel_id
      INTO v_staff_active, v_staff_hostel_id
      FROM staff
     WHERE id = p_staff_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Staff member not found';
    END IF;

    IF NOT v_staff_active THEN
        RAISE EXCEPTION 'Staff member is not active';
    END IF;

    IF v_staff_hostel_id IS NOT NULL AND v_staff_hostel_id <> v_complaint_hostel_id THEN
        RAISE EXCEPTION 'Staff member does not belong to this hostel';
    END IF;

    UPDATE complaints
       SET status = 'assigned',
           assigned_staff_id = p_staff_id,
           assigned_at = NOW(),
           updated_at = NOW()
     WHERE id = p_complaint_id;

    INSERT INTO complaint_history (
        complaint_id, previous_status, new_status, changed_by, remarks
    ) VALUES (
        p_complaint_id, v_current_status, 'assigned', v_profile_id,
        'Complaint assigned to staff'
    );
END;
$$;
