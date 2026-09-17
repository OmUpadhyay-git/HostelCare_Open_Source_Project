-- ============================================================================
-- HOSTELCARE SEED DATA
-- Migration 002: Initial Categories
-- ============================================================================

-- Insert initial complaint categories
INSERT INTO complaint_categories (name, description, sla_hours, default_priority, responsible_department) VALUES
    ('Electrical', 'Electrical wiring, switches, sockets, and power issues', 48, 'high', 'Electrical'),
    ('Plumbing', 'Water pipes, taps, drains, and plumbing fixtures', 48, 'high', 'Plumbing'),
    ('Water', 'Water supply issues, Tanker water, Borewell problems', 24, 'high', 'Plumbing'),
    ('Cleaning', 'Room cleaning, bathroom cleaning, common area cleaning', 24, 'medium', 'Housekeeping'),
    ('Furniture', 'Bed, desk, chair, cupboard repairs and replacements', 72, 'medium', 'Maintenance'),
    ('Room Maintenance', 'Walls, doors, windows, flooring repairs', 72, 'medium', 'Maintenance'),
    ('Wi-Fi / Internet', 'WiFi connectivity, router issues, network problems', 48, 'medium', 'IT'),
    ('Mess / Food', 'Food quality, hygiene, mess timing issues', 12, 'high', 'Mess'),
    ('Laundry', 'Laundry service issues, washing machine problems', 48, 'low', 'Housekeeping'),
    ('Security', 'Security concerns, lock issues, access problems', 24, 'urgent', 'Security'),
    ('Air Conditioning', 'AC not working, cooling issues, maintenance', 48, 'medium', 'HVAC'),
    ('Fan', 'Ceiling fan, table fan, exhaust fan issues', 48, 'medium', 'Electrical'),
    ('Light', 'Tube light, LED, bulb replacement', 48, 'low', 'Electrical'),
    ('Bathroom', 'Bathroom fittings, shower, geyser issues', 24, 'high', 'Plumbing'),
    ('Other', 'General complaints not covered by other categories', 72, 'medium', 'General');
