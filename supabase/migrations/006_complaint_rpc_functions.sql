-- ============================================================================
-- HOSTELCARE DATABASE SCHEMA
-- Migration 006: Complaint Action RPC Functions
-- ============================================================================

-- ============================================================================
-- verify_complaint
-- Called by student after status = 'resolved'
-- verified = true  -> sets status = 'verified' (then warden closes)
-- verified = false -> sets status = 'reopened'
-- ============================================================================
CREATE OR REPLACE FUNCTION verify_complaint(
    p_complaint_id UUID,
    p_verified BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_profile_id UUID := auth.uid();
    v_current_status complaint_status;
    v_student_id UUID;
BEGIN
    -- Look up complaint current state and owning student
    SELECT status, student_id
      INTO v_current_status, v_student_id
      FROM complaints
     WHERE id = p_complaint_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Complaint not found';
    END IF;

    -- Only the owning student may verify
    IF v_student_id <> v_profile_id THEN
        RAISE EXCEPTION 'Only the owning student can verify this complaint';
    END IF;

    -- Must be in resolved status
    IF v_current_status <> 'resolved' THEN
        RAISE EXCEPTION 'Only resolved complaints can be verified (current status: %)', v_current_status;
    END IF;

    IF p_verified THEN
        -- Student confirms resolution -> verified
        UPDATE complaints
           SET status = 'verified',
               updated_at = NOW()
         WHERE id = p_complaint_id;

        INSERT INTO complaint_history (
            complaint_id, previous_status, new_status, changed_by, remarks
        ) VALUES (
            p_complaint_id, v_current_status, 'verified', v_profile_id,
            'Student verified the resolution'
        );
    ELSE
        -- Student reports not fixed -> reopened
        UPDATE complaints
           SET status = 'reopened',
               updated_at = NOW()
         WHERE id = p_complaint_id;

        INSERT INTO complaint_history (
            complaint_id, previous_status, new_status, changed_by, remarks
        ) VALUES (
            p_complaint_id, v_current_status, 'reopened', v_profile_id,
            'Student reported the issue is not fixed'
        );
    END IF;
END;
$$;

-- ============================================================================
-- reopen_complaint
-- Called by student after status = 'verified'
-- Sets status back to 'reopened' so warden/staff must address again.
-- ============================================================================
CREATE OR REPLACE FUNCTION reopen_complaint(
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
    v_student_id UUID;
BEGIN
    SELECT status, student_id
      INTO v_current_status, v_student_id
      FROM complaints
     WHERE id = p_complaint_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Complaint not found';
    END IF;

    IF v_student_id <> v_profile_id THEN
        RAISE EXCEPTION 'Only the owning student can reopen this complaint';
    END IF;

    IF v_current_status <> 'verified' THEN
        RAISE EXCEPTION 'Only verified complaints can be reopened (current status: %)', v_current_status;
    END IF;

    UPDATE complaints
       SET status = 'reopened',
           updated_at = NOW()
     WHERE id = p_complaint_id;

    INSERT INTO complaint_history (
        complaint_id, previous_status, new_status, changed_by, remarks
    ) VALUES (
        p_complaint_id, v_current_status, 'reopened', v_profile_id,
        COALESCE(NULLIF(p_reason, ''), 'Student reopened the complaint')
    );
END;
$$;

-- ============================================================================
-- cancel_complaint
-- Called by student while status = 'pending' or 'accepted' (before work starts)
-- Sets status to 'cancelled'.
-- ============================================================================
CREATE OR REPLACE FUNCTION cancel_complaint(
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
    v_student_id UUID;
BEGIN
    SELECT status, student_id
      INTO v_current_status, v_student_id
      FROM complaints
     WHERE id = p_complaint_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Complaint not found';
    END IF;

    IF v_student_id <> v_profile_id THEN
        RAISE EXCEPTION 'Only the owning student can cancel this complaint';
    END IF;

    -- Allow cancellation only before work begins
    IF v_current_status NOT IN ('pending', 'accepted') THEN
        RAISE EXCEPTION 'Cannot cancel complaint in status: %. Only pending or accepted complaints can be cancelled.', v_current_status;
    END IF;

    UPDATE complaints
       SET status = 'cancelled',
           updated_at = NOW()
     WHERE id = p_complaint_id;

    INSERT INTO complaint_history (
        complaint_id, previous_status, new_status, changed_by, remarks
    ) VALUES (
        p_complaint_id, v_current_status, 'cancelled', v_profile_id,
        'Student cancelled the complaint'
    );
END;
$$;
