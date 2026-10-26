import csv
import sqlite3
from pathlib import Path

BASE = Path(__file__).resolve().parent
CSV_FILE = BASE / "workshop_signups.csv"
SCHEMA_FILE = BASE / "schema.sql"
DB_FILE = BASE / "workshops.db"


def main():
    if not CSV_FILE.exists():
        print("ERROR: workshop_signups.csv not found.")
        return

    if not SCHEMA_FILE.exists():
        print("ERROR: schema.sql not found.")
        return

    # Read the CSV file.
    with CSV_FILE.open("r", encoding="utf-8-sig", newline="") as file:
        rows = list(csv.DictReader(file))

    # Build the database from the beginning.
    if DB_FILE.exists():
        DB_FILE.unlink()

    connection = sqlite3.connect(DB_FILE)
    connection.execute("PRAGMA foreign_keys = ON")

    try:
        connection.executescript(
            SCHEMA_FILE.read_text(encoding="utf-8")
        )

        workshops = {}
        rejected = []
        workshop_count = 0
        attendee_count = 0

        # Insert parent records first.
        for line_number, row in enumerate(rows, start=2):
            code = row["workshop_code"].strip()

            if code in workshops:
                continue

            try:
                if not code:
                    raise ValueError("Missing workshop code")

                title = row["workshop_title"].strip()
                date = row["workshop_date"].strip()
                location = row["location"].strip()
                format_value = row["format"].strip()
                instructor = row["instructor"].strip()
                capacity = int(row["capacity"].strip())

                if not all([title, date, location, instructor]):
                    raise ValueError("Missing workshop information")

                cursor = connection.execute(
                    """
                    INSERT INTO workshops
                    (workshop_code, workshop_title,
                     workshop_date, location, format,
                     instructor, capacity)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    (code, title, date, location,
                     format_value, instructor, capacity)
                )

                workshops[code] = cursor.lastrowid
                workshop_count += 1

            except (ValueError, sqlite3.IntegrityError) as error:
                rejected.append(
                    f"Line {line_number}: {error}"
                )

        # Insert child records after parents.
        for line_number, row in enumerate(rows, start=2):
            first = row["first_name"].strip()
            last = row["last_name"].strip()
            email = row["email"].strip().lower()
            code = row["workshop_code"].strip()

            # Empty attendee fields mean no signup.
            if not first and not last and not email:
                continue

            try:
                if not first or not last or not email:
                    raise ValueError("Incomplete attendee information")

                if "@" not in email or "." not in email.split("@")[-1]:
                    raise ValueError("Invalid email address")

                if code not in workshops:
                    raise ValueError("Workshop does not exist")

                connection.execute(
                    """
                    INSERT INTO attendees
                    (workshop_id, first_name, last_name, email)
                    VALUES (?, ?, ?, ?)
                    """,
                    (workshops[code], first, last, email)
                )

                attendee_count += 1

            except (ValueError, sqlite3.IntegrityError) as error:
                rejected.append(
                    f"Line {line_number}: {error}"
                )

        connection.commit()

        print(f"Workshops inserted: {workshop_count}")
        print(f"Attendees inserted: {attendee_count}")
        print(f"Rejected rows: {len(rejected)}")

        for message in rejected:
            print("REJECTED:", message)

    finally:
        connection.close()


if __name__ == "__main__":
    main()
