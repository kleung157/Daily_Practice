CREATE TABLE student(
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE course CASCADE;
CREATE TABLE course (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE roster CASCADE;
CREATE TABLE roster (
    id SERIAL,
    student_id INTEGER REFERENCES student(id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
    role INTEGER,
    UNIQUE(student_id, course_id),
    PRIMARY KEY(id)
);

INSERT INTO student (name) VALUES ('Ashbey');
INSERT INTO student (name) VALUES ('Alanah');
INSERT INTO student (name) VALUES ('Eva');
INSERT INTO student (name) VALUES ('Maros');
INSERT INTO student (name) VALUES ('Ramandeep');
INSERT INTO student (name) VALUES ('Nora');
INSERT INTO student (name) VALUES ('Jole');
INSERT INTO student (name) VALUES ('Jordon');
INSERT INTO student (name) VALUES ('Marrwa');
INSERT INTO student (name) VALUES ('Sadiqa');
INSERT INTO student (name) VALUES ('Sanjana');
INSERT INTO student (name) VALUES ('Emmie');
INSERT INTO student (name) VALUES ('Kaelynn');
INSERT INTO student (name) VALUES ('Karleigh');
INSERT INTO student (name) VALUES ('Zeek');

INSERT INTO course (title) VALUES ('si106');
INSERT INTO course (title) VALUES ('si110');
INSERT INTO course (title) VALUES ('si206');

INSERT INTO roster (student_id, course_id, role) VALUES (1, 1, 1);
INSERT INTO roster (student_id, course_id, role) VALUES (2, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (3, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (4, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (5, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (6, 2, 1);
INSERT INTO roster (student_id, course_id, role) VALUES (7, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (8, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (9, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (10, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (11, 3, 1);
INSERT INTO roster (student_id, course_id, role) VALUES (12, 3, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (13, 3, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (14, 3, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (15, 3, 0);

SELECT 
    s.name, 
    c.title, 
    r.role
FROM student AS s
JOIN roster AS r
    ON s.id = r.student_id
JOIN course AS c
    ON c.id = r.course_id
ORDER BY 
    c.title ASC,
    r.ROLE DESC,
    s.name ASC;
    
