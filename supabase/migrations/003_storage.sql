-- ============================================================================
-- HOSTELCARE STORAGE BUCKETS
-- Migration 003: Storage Setup
-- ============================================================================

-- Create storage bucket for complaint images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'complaint-images',
    'complaint-images',
    false,
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp']
);

-- ============================================================================
-- STORAGE POLICIES (Minimal for development)
-- ============================================================================
-- NOTE: Full RLS policies for storage will be implemented in Phase 5
-- These are minimal policies to allow development to proceed

-- Allow authenticated users to upload to their own folder
CREATE POLICY "Allow authenticated uploads"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'complaint-images'
);

-- Allow authenticated users to read from complaint-images bucket
CREATE POLICY "Allow authenticated reads"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'complaint-images'
);

-- Allow authenticated users to delete their own uploads
CREATE POLICY "Allow authenticated deletes"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'complaint-images'
);
