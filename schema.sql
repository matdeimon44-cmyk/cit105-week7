PRAGMA foreign_keys = ON;

-- Parent table: workshops
CREATE TABLE workshops (
    workshop_id INTEGER PRIMARY KEY,
    workshop_code TEXT NOT NULL UNIQUE,
    workshop_title TEXT NOT NULL,
    workshop_date TEXT NOT NULL,
    location TEXT NOT NULL,
    format TEXT NOT NULL
        CHECK (format IN ('In-person', 'Online', 'Hybrid')),
    instructor TEXT NOT NULL,
    capacity INTEGER NOT NULL
        CHECK (capacity > 0)
);

-- Child table: attendees
CREATE TABLE attendees (
    attendee_id INTEGER PRIMARY KEY,
    workshop_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL
        CHECK (length(trim(email)) > 0),

    -- An email can register only once per workshop.
    UNIQUE (workshop_id, email),

    FOREIGN KEY (workshop_id)
        REFERENCES workshops(workshop_id)
);
