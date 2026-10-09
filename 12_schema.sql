-- 12-жұмыс. ERD → SQL (SQLite/PostgreSQL үйлесімді нұсқа). UMP
-- ERD: users 1—N enrollments N—1 courses; courses 1—N materials; courses 1—N assignments;
--      assignments 1—N submissions N—1 users; materials 1—N material_versions

PRAGMA foreign_keys = ON;

CREATE TABLE users (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    email         TEXT NOT NULL UNIQUE CHECK (email LIKE '%@univ.edu.kz'),
    password_hash TEXT NOT NULL,
    full_name     TEXT NOT NULL,
    role          TEXT NOT NULL CHECK (role IN ('student','teacher','admin')),
    is_active     INTEGER NOT NULL DEFAULT 1,
    created_at    TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE groups (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE group_members (
    group_id INTEGER NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id  INTEGER NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    PRIMARY KEY (group_id, user_id)
);

CREATE TABLE courses (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    code       TEXT NOT NULL UNIQUE,
    title      TEXT NOT NULL,
    teacher_id INTEGER NOT NULL REFERENCES users(id)
);

CREATE TABLE enrollments (
    course_id INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    user_id   INTEGER NOT NULL REFERENCES users(id)   ON DELETE CASCADE,
    PRIMARY KEY (course_id, user_id)
);

CREATE TABLE materials (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id   INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title       TEXT NOT NULL,
    tags        TEXT,
    uploaded_by INTEGER NOT NULL REFERENCES users(id),
    created_at  TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE material_versions (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    version_no  INTEGER NOT NULL CHECK (version_no >= 1),
    file_path   TEXT NOT NULL,
    file_size   INTEGER NOT NULL CHECK (file_size <= 52428800),  -- 50 МБ (NFR-04)
    file_type   TEXT NOT NULL CHECK (file_type IN ('pdf','docx','pptx')),
    created_at  TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (material_id, version_no)
);

CREATE TABLE assignments (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id   INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title       TEXT NOT NULL,
    description TEXT,
    due_at      TEXT NOT NULL,
    created_at  TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE submissions (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    assignment_id INTEGER NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    student_id    INTEGER NOT NULL REFERENCES users(id),
    file_path     TEXT NOT NULL,
    submitted_at  TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    grade         INTEGER CHECK (grade BETWEEN 0 AND 100),
    feedback      TEXT,
    status        TEXT NOT NULL DEFAULT 'submitted' CHECK (status IN ('submitted','graded')),
    UNIQUE (assignment_id, student_id)
);

CREATE TABLE notifications (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message    TEXT NOT NULL,
    is_read    INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_materials_course ON materials(course_id);
CREATE INDEX idx_materials_title  ON materials(title);
CREATE INDEX idx_submissions_asg  ON submissions(assignment_id);
