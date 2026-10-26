-- 1. List every workshop, with the most recent first.
SELECT * FROM workshops ORDER BY workshop_date DESC;

-- 2. Count attendees on each workshop, including workshops with none.
SELECT w.workshop_id, w.workshop_title, COUNT(a.attendee_id) AS attendee_count
FROM workshops AS w
LEFT JOIN attendees AS a ON w.workshop_id = a.workshop_id
GROUP BY w.workshop_id, w.workshop_title
ORDER BY w.workshop_id;

-- 3. List every attendee together with the title of the workshop they signed up for, using a join.
SELECT a.attendee_id, a.first_name, a.last_name, a.email, w.workshop_title
FROM attendees AS a
JOIN workshops AS w ON a.workshop_id = w.workshop_id;

-- 4. Find every attendee whose email address is not from the .edu domain.
SELECT * FROM attendees WHERE LOWER(TRIM(email)) NOT LIKE '%.edu';

-- 5. Find the workshop with the largest number of attendees.
SELECT w.workshop_id, w.workshop_title, COUNT(a.attendee_id) AS attendee_count
FROM workshops AS w
LEFT JOIN attendees AS a ON w.workshop_id = a.workshop_id
GROUP BY w.workshop_id, w.workshop_title
ORDER BY attendee_count DESC
LIMIT 1;

-- 6. Update one workshop's location, changing exactly one row.
UPDATE workshops
SET location = 'Room 305'
WHERE workshop_id = 1;

SELECT changes() AS rows_updated;

-- 7. Delete a single attendee by id, and show that their workshop still exists afterward.
DELETE FROM attendees
WHERE attendee_id = 1;

SELECT changes() AS rows_deleted;

SELECT workshop_id, workshop_title
FROM workshops
WHERE workshop_id = 1;

-- 8. Insert a new workshop with no attendees.
INSERT INTO workshops
(workshop_code, workshop_title, workshop_date,
 location, format, instructor, capacity)
VALUES
('WS999', 'Advanced Python Workshop',
 '2026-12-15', 'Room 205', 'In-person',
 'Prof. Smith', 25);

-- Verify that the workshop exists with zero attendees.
SELECT w.workshop_title,
       COUNT(a.attendee_id) AS attendee_count
FROM workshops AS w
LEFT JOIN attendees AS a
ON w.workshop_id = a.workshop_id
WHERE w.workshop_code = 'WS999'
GROUP BY w.workshop_id, w.workshop_title;
FROM workshops AS w
LEFT JOIN attendees AS a ON w.workshop_id = a.workshop_id
WHERE w.workshop_code = 'NEW-WK7-001'
GROUP BY w.workshop_id, w.workshop_title;
