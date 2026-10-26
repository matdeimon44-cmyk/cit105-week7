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
UPDATE workshops SET location = 'Room 205'
WHERE workshop_id = (SELECT MIN(workshop_id) FROM workshops);
SELECT changes() AS rows_updated;

-- 7. Delete a single attendee by id, and show that their workshop still exists afterward.
DELETE FROM attendees WHERE attendee_id = (SELECT MIN(attendee_id) FROM attendees);
SELECT changes() AS rows_deleted;
SELECT w.workshop_id, w.workshop_title
FROM workshops AS w
WHERE w.workshop_id = (SELECT MIN(workshop_id) FROM workshops);

-- 8. Insert a new workshop with no attendees, proving the insert anomaly is gone.
INSERT INTO workshops (workshop_code, workshop_title, workshop_date, location, format, instructor, capacity)
VALUES ('NEW-WK7-001', 'Independent Workshop', '2026-12-01', 'Room 205', 'In-Person', 'TBA', 20);
SELECT w.workshop_id, w.workshop_title, COUNT(a.attendee_id) AS attendee_count
FROM workshops AS w
LEFT JOIN attendees AS a ON w.workshop_id = a.workshop_id
WHERE w.workshop_code = 'NEW-WK7-001'
GROUP BY w.workshop_id, w.workshop_title;
