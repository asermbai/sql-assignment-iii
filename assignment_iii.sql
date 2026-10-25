-- =============================================================================
-- ASSIGNMENT III: SQL TABLE MANIPULATION
-- Project   : Student Registration System
-- Student   : DAUGLA DOURAH NGUEMADJIMBAYE (Student ID 202512707)
-- DBMS      : PostgreSQL
-- Database  : daugla_202512707_student_registration
-- Statements are listed in the order in which they are executed.
-- =============================================================================

-- =============================================================================
-- SECTION 1: DATABASE CREATION
-- =============================================================================
-- Objective: create the database using the required name format yourname_studentid_projectname.
-- Run this statement while connected to the default 'postgres' database.
CREATE DATABASE daugla_202512707_student_registration;

-- >>> Now open a NEW Query Tool on the database daugla_202512707_student_registration
-- >>> (pgAdmin: right-click the database > Query Tool;  psql: \c daugla_202512707_student_registration)
-- >>> and run everything below it.

-- =============================================================================
-- SECTION 2: TABLE CREATION AND CONSTRAINTS
-- =============================================================================
-- Objective: create four related tables. Parent tables first (departments), then the child tables.
-- Every primary key is GENERATED ALWAYS AS IDENTITY, so PostgreSQL creates the values automatically.
-- departments  = parent of courses and students
-- courses      = child of departments
-- students     = child of departments
-- registrations= child of students AND courses (links the two)

CREATE TABLE departments (
    department_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name  VARCHAR(100) NOT NULL UNIQUE,
    building         VARCHAR(50)  NOT NULL
);

CREATE TABLE courses (
    course_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_code    VARCHAR(10)  NOT NULL UNIQUE,
    course_title   VARCHAR(120) NOT NULL,
    credits        INT          NOT NULL CHECK (credits BETWEEN 1 AND 6),
    department_id  INT          NOT NULL,
    CONSTRAINT fk_courses_department
        FOREIGN KEY (department_id) REFERENCES departments (department_id)
);

CREATE TABLE students (
    student_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reg_number       VARCHAR(15)  NOT NULL UNIQUE,
    first_name       VARCHAR(50)  NOT NULL,
    last_name        VARCHAR(50)  NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE,
    date_of_birth    DATE         NOT NULL CHECK (date_of_birth > DATE '1950-01-01'),
    gender           VARCHAR(10)  NOT NULL CHECK (gender IN ('Male', 'Female')),
    enrollment_date  DATE         NOT NULL DEFAULT CURRENT_DATE,
    status           VARCHAR(12)  NOT NULL DEFAULT 'Active'
                     CHECK (status IN ('Active', 'Suspended', 'Graduated')),
    department_id    INT          NOT NULL,
    CONSTRAINT fk_students_department
        FOREIGN KEY (department_id) REFERENCES departments (department_id)
);

CREATE TABLE registrations (
    registration_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id         INT          NOT NULL,
    course_id          INT          NOT NULL,
    semester           VARCHAR(20)  NOT NULL,
    registration_date  DATE         NOT NULL DEFAULT CURRENT_DATE,
    status             VARCHAR(12)  NOT NULL DEFAULT 'Registered'
                       CHECK (status IN ('Registered', 'Dropped', 'Completed', 'Failed')),
    grade              NUMERIC(5,2) CHECK (grade BETWEEN 0 AND 100),
    CONSTRAINT fk_registrations_student
        FOREIGN KEY (student_id) REFERENCES students (student_id),
    CONSTRAINT fk_registrations_course
        FOREIGN KEY (course_id) REFERENCES courses (course_id),
    CONSTRAINT uq_student_course_semester UNIQUE (student_id, course_id, semester)
);

-- =============================================================================
-- SECTION 3: INITIAL DATA INSERTION
-- =============================================================================
-- Objective: insert at least five records into every table, parent tables before child tables.
-- The primary-key columns are never listed, so the database generates them.

-- Parent table first: departments (department_id is generated automatically)
INSERT INTO departments (department_name, building) VALUES
('Computer Science',        'Block A'),
('Business Administration', 'Block B'),
('Law',                     'Block C'),
('Education',               'Block D'),
('Public Health',           'Block E');

-- Courses (child of departments). department_id 1..5 = the departments inserted above, in order.
INSERT INTO courses (course_code, course_title, credits, department_id) VALUES
('CS101',  'Introduction to Programming', 4, 1),
('CS201',  'Database Systems',            3, 1),
('BA101',  'Principles of Management',    3, 2),
('LAW101', 'Introduction to Law',         3, 3),
('EDU105', 'Educational Psychology',      2, 4);

-- Students (child of departments)
INSERT INTO students (reg_number, first_name, last_name, email, date_of_birth, gender, enrollment_date, status, department_id) VALUES
('REG-2022-001', 'Jean Claude', 'Habimana',  'jc.habimana@example.com', '2000-03-14', 'Male',   '2022-09-05', 'Active',    1),
('REG-2022-002', 'Aline',       'Uwase',     'aline.uwase@example.com', '2001-07-22', 'Female', '2022-09-05', 'Active',    2),
('REG-2024-001', 'Patrick',     'Niyonzima', 'p.niyonzima@example.com', '2004-05-18', 'Male',   '2024-09-02', 'Active',    1),
('REG-2025-001', 'Sandrine',    'Uwimana',   's.uwimana@example.com',   '2004-09-09', 'Female', '2025-09-01', 'Active',    2),
('REG-2026-001', 'Claudine',    'Mutesi',    'c.mutesi@example.com',    '2005-12-25', 'Female', '2026-01-12', 'Suspended', 3);

-- Registrations (child of students AND courses). student_id 1..5 and course_id 1..5 as inserted above.
INSERT INTO registrations (student_id, course_id, semester, registration_date, status, grade) VALUES
(1, 1, 'Semester 1 2026', '2026-01-20', 'Completed',  78.50),
(1, 2, 'Semester 1 2026', '2026-01-20', 'Completed',  82.00),
(2, 3, 'Semester 1 2026', '2026-01-21', 'Registered', 67.25),
(3, 1, 'Semester 1 2026', '2026-01-23', 'Registered', 45.50),
(4, 3, 'Semester 1 2026', '2026-01-24', 'Registered', 64.00);

-- Verification 1: number of records per table (each must be at least 5)
SELECT 'departments' AS table_name, COUNT(*) AS total_rows FROM departments
UNION ALL SELECT 'courses',       COUNT(*) FROM courses
UNION ALL SELECT 'students',      COUNT(*) FROM students
UNION ALL SELECT 'registrations', COUNT(*) FROM registrations;

-- Verification 2: the generated primary keys of the parent table
SELECT department_id, department_name, building FROM departments ORDER BY department_id;

-- Verification 3: foreign keys work (no orphan rows)
-- Foreign-key check: rows whose parent does not exist (every result must be 0)
SELECT
  (SELECT COUNT(*) FROM courses c       LEFT JOIN departments d ON d.department_id = c.department_id WHERE d.department_id IS NULL) AS courses_without_department,
  (SELECT COUNT(*) FROM students s      LEFT JOIN departments d ON d.department_id = s.department_id WHERE d.department_id IS NULL) AS students_without_department,
  (SELECT COUNT(*) FROM registrations r LEFT JOIN students s    ON s.student_id    = r.student_id    WHERE s.student_id IS NULL)    AS registrations_without_student,
  (SELECT COUNT(*) FROM registrations r LEFT JOIN courses c     ON c.course_id     = r.course_id     WHERE c.course_id IS NULL)     AS registrations_without_course;

-- =============================================================================
-- >>> GENERATE THE ERD NOW (after all tables exist and BEFORE the ALTER TABLE tasks)
-- >>> pgAdmin 4: right-click the database > ERD For Database > Download image  (save as erd.png)
-- =============================================================================

-- =============================================================================
-- SECTION 4: SELECT TASKS
-- =============================================================================

-- Q1.1: Basic Data Retrieval
-- Objective: Display the registration number, name and email of every student, choosing only the columns that are useful.
SELECT reg_number, first_name, last_name, email
FROM students;

-- Q1.2: Conditional Data Retrieval
-- Objective: List the active students who were born on or after 1 January 2004.
SELECT reg_number, first_name, last_name, date_of_birth, status
FROM students
WHERE status = 'Active'
  AND date_of_birth >= '2004-01-01';

-- Q1.3: Sorted Data Retrieval
-- Objective: List the courses from the highest to the lowest number of credits.
SELECT course_code, course_title, credits
FROM courses
ORDER BY credits DESC, course_code ASC;


-- =============================================================================
-- SECTION 5: JOIN TASKS
-- =============================================================================

-- Q2.1: INNER JOIN
-- Objective: Show each student together with the name of their department.
SELECT s.reg_number, s.first_name, s.last_name, d.department_name
FROM students s
INNER JOIN departments d ON d.department_id = s.department_id
ORDER BY d.department_name, s.last_name;

-- Q2.2: LEFT JOIN
-- Objective: Show every course with the number of registrations it has, including courses nobody has registered for.
SELECT c.course_code, c.course_title, COUNT(r.registration_id) AS total_registrations
FROM courses c
LEFT JOIN registrations r ON r.course_id = c.course_id
GROUP BY c.course_id, c.course_code, c.course_title
ORDER BY total_registrations DESC, c.course_code;

-- Q2.3: Multi-Table JOIN
-- Objective: Produce a registration report joining four tables: registrations, students, courses and the department that offers each course.
SELECT s.reg_number,
       s.first_name || ' ' || s.last_name AS student,
       c.course_code,
       c.course_title,
       d.department_name AS course_department,
       r.semester,
       r.status,
       r.grade
FROM registrations r
JOIN students s    ON s.student_id    = r.student_id
JOIN courses c     ON c.course_id     = r.course_id
JOIN departments d ON d.department_id = c.department_id
ORDER BY r.semester, s.last_name, c.course_code;


-- =============================================================================
-- SECTION 6: UPDATE TASKS AND VERIFICATION
-- =============================================================================

-- Q3.1: Update One Record
-- Objective: Change the email address of one student, identified by the unique registration number REG-2024-001.
-- Identify the record (before)
SELECT student_id, reg_number, first_name, last_name, email
FROM students
WHERE reg_number = 'REG-2024-001';

-- Execute the update
UPDATE students
SET email = 'patrick.niyonzima@example.com'
WHERE reg_number = 'REG-2024-001';

-- Verify the change (after)
SELECT student_id, reg_number, first_name, last_name, email
FROM students
WHERE reg_number = 'REG-2024-001';

-- Q3.2: Update Multiple Records
-- Objective: Mark as Graduated every active student who enrolled before 2023 (the 2022 intake that has finished its final semester).
-- Identify the records (before)
SELECT reg_number, first_name, last_name, enrollment_date, status
FROM students
WHERE enrollment_date < '2023-01-01'
  AND status = 'Active';

-- Execute the update
UPDATE students
SET status = 'Graduated'
WHERE enrollment_date < '2023-01-01'
  AND status = 'Active';

-- Verify the change (after)
SELECT reg_number, first_name, last_name, enrollment_date, status
FROM students
WHERE enrollment_date < '2023-01-01';

-- Q3.3: Conditional Update
-- Objective: Apply the business rule: once a grade is posted, a registration with grade 50 or more becomes Completed, and below 50 becomes Failed.
-- Identify the records (before)
SELECT registration_id, student_id, course_id, grade, status
FROM registrations
WHERE status = 'Registered'
  AND grade IS NOT NULL
ORDER BY registration_id;

-- Execute the update
UPDATE registrations
SET status = CASE
                WHEN grade >= 50 THEN 'Completed'
                ELSE 'Failed'
            END
WHERE status = 'Registered'
  AND grade IS NOT NULL;

-- Verify the change (after)
SELECT registration_id, student_id, course_id, grade, status
FROM registrations
WHERE grade IS NOT NULL
ORDER BY registration_id;


-- =============================================================================
-- SECTION 7: ALTER TABLE TASKS AND VERIFICATION
-- =============================================================================

-- Q4.1: Rename a Column
-- Objective: Rename departments.building to building_name so the column name is more descriptive.
-- Execute
ALTER TABLE departments
RENAME COLUMN building TO building_name;

-- Verify the new name
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'departments'
ORDER BY ordinal_position;

-- Verify the data is still accessible
SELECT department_name, building_name
FROM departments
ORDER BY department_name;

-- Q4.2: Change a Column's Data Type
-- Objective: Change courses.credits from INT to SMALLINT, because credits are small numbers between 1 and 6.
-- Check that the values convert safely
SELECT MIN(credits) AS smallest, MAX(credits) AS largest
FROM courses;

-- Execute
ALTER TABLE courses
ALTER COLUMN credits TYPE SMALLINT;

-- Verify the new structure
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'courses'
ORDER BY ordinal_position;

-- Verify the data is still valid
SELECT course_code, course_title, credits
FROM courses
ORDER BY course_code;

-- Q4.3: Add a Column
-- Objective: Add a phone column to students so the registrar can contact students by telephone.
-- Execute
ALTER TABLE students
ADD COLUMN phone VARCHAR(20);

-- Verify the new structure
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'students'
ORDER BY ordinal_position;

-- Verify existing rows
SELECT reg_number, first_name, phone
FROM students
ORDER BY student_id
LIMIT 5;


-- =============================================================================
-- SECTION 8: ADDITIONAL INSERT TASKS AND VERIFICATION
-- =============================================================================

-- Q5.1: Insert a Single Record
-- Objective: Insert one new department, Information Systems. The key department_id is generated automatically.
-- Execute
INSERT INTO departments (department_name, building_name)
VALUES ('Information Systems', 'Block F');

-- Verify
SELECT department_id, department_name, building_name
FROM departments
ORDER BY department_id;

-- Q5.2: Insert Multiple Records
-- Objective: Insert three new Computer Science students in one statement, including the new phone column.
-- Execute
INSERT INTO students (reg_number, first_name, last_name, email, date_of_birth, gender, enrollment_date, department_id, phone)
VALUES
('REG-2026-002', 'Diane',    'Umutoni',    'd.umutoni@example.com',   '2006-03-11', 'Female', '2026-09-14',
    (SELECT department_id FROM departments WHERE department_name = 'Computer Science'), '0788400001'),
('REG-2026-003', 'Kevin',    'Ndayisaba',  'k.ndayisaba@example.com', '2005-10-27', 'Male',   '2026-09-14',
    (SELECT department_id FROM departments WHERE department_name = 'Computer Science'), '0788400002'),
('REG-2026-004', 'Beatrice', 'Mukashema',  'b.mukashema@example.com', '2006-01-15', 'Female', '2026-09-14',
    (SELECT department_id FROM departments WHERE department_name = 'Computer Science'), '0788400003');

-- Verify
SELECT student_id, reg_number, first_name, last_name, status, department_id, phone
FROM students
WHERE reg_number IN ('REG-2026-002', 'REG-2026-003', 'REG-2026-004')
ORDER BY student_id;

-- Q5.3: Insert a Related Record
-- Objective: Register the new student REG-2026-002 for the course CS101. The foreign keys must reference existing parent rows.
-- Execute
INSERT INTO registrations (student_id, course_id, semester, registration_date)
VALUES (
    (SELECT student_id FROM students WHERE reg_number = 'REG-2026-002'),
    (SELECT course_id  FROM courses  WHERE course_code = 'CS101'),
    'Semester 2 2026',
    '2026-09-20'
);

-- Verify (with a JOIN)
SELECT r.registration_id, s.reg_number, s.first_name, c.course_code, r.semester, r.status
FROM registrations r
JOIN students s ON s.student_id = r.student_id
JOIN courses c  ON c.course_id  = r.course_id
WHERE s.reg_number = 'REG-2026-002';


-- =============================================================================
-- APPENDIX: OPTIONAL CONSTRAINT TESTS (run last, ONE at a time; each must fail with an error)
-- =============================================================================
-- A failed INSERT still uses up an identity number, so these are run after all the tasks.
-- Foreign key test (student 999 does not exist):
-- INSERT INTO registrations (student_id, course_id, semester) VALUES (999, 1, 'Semester 2 2026');
-- Check constraint test (credits must be between 1 and 6):
-- INSERT INTO courses (course_code, course_title, credits, department_id) VALUES ('XX999', 'Invalid Course', 9, 1);
