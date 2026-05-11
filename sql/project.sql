

CREATE SCHEMA project;

CREATE TABLE project.students (
    student_id INT PRIMARY KEY,
    gender TEXT,
    age INT,
    address TEXT,
    nursery TEXT,
    internet TEXT,
    romantic TEXT
);


CREATE TABLE project.performance (
    student_id INT PRIMARY KEY REFERENCES project.students(student_id),
    subject TEXT,
    absence_days INT,
    first_grade INT,
    second_grade INT,
    final_grade INT,
    avg_grade FLOAT,
    status TEXT,
    level TEXT
);


CREATE TABLE project.academic_context (
    student_id INT PRIMARY KEY REFERENCES project.students(student_id),
    school TEXT,
    reason TEXT,
    travel_time TEXT,
    study_time TEXT,
    family_support TEXT,
    school_support TEXT,
    paid TEXT,
    activities TEXT,
    wants_higher_education TEXT
);


CREATE TABLE project.family_background (
    student_id INT PRIMARY KEY REFERENCES project.students(student_id),
    family_size TEXT,
    parents_status TEXT,
    mother_education TEXT,
    father_education TEXT,
    mother_job TEXT,
    father_job TEXT,
    guardian TEXT,
    family_relationship_quality TEXT
);


CREATE TABLE project.lifestyle_health (
    student_id INT PRIMARY KEY  REFERENCES project.students(student_id),
    freetime TEXT,
    go_out TEXT,
    health TEXT,
    failures INT
);


INSERT INTO project.students
SELECT DISTINCT
    student_id,
    gender,
    age,
    address,
    nursery,
    internet,
    romantic
FROM public.data;


INSERT INTO project.performance
SELECT
    student_id,
    subject,
    absence_days,
    first_grade,
    second_grade,
    final_grade,
    avg_grade,
    status,
    level
FROM public.data;


INSERT INTO project.academic_context
SELECT DISTINCT
    student_id,
    school,
    reason,
    travel_time,
    study_time,
    family_support,
    school_support,
    paid,
    activities,
    wants_higher_education
FROM public.data;


INSERT INTO project.family_background
SELECT DISTINCT
    student_id,
    family_size,
    parents_status,
    mother_education,
    father_education,
    mother_job,
    father_job,
    guardian,
    family_relationship_quality
FROM public.data;


UPDATE project.family_background
SET mother_education = 'None'
WHERE mother_education IS NULL;

UPDATE project.family_background
SET father_education = 'None'
WHERE father_education IS NULL;


INSERT INTO project.lifestyle_health
SELECT DISTINCT
    student_id,
    freetime,
    go_out,
    health,
    failures
FROM public.data;


/* ============================================================
   STUDENT PERFORMANCE DASHBOARD - SQL QUERIES
   Model: Students | Performance | Academic_Context |
          Family_Background | Lifestyle_Health
   ============================================================ */
 
 
/* ============================================================
   SECTION 1 — CORE KPIs (Single-value cards for Power BI)
   ============================================================ */


-- KPI 1: Average Student Score (avg_grade across all students)
SELECT 
   round(AVG(p.avg_grade))  AS avg_student_score
FROM performance p;



-- KPI 2: Average Study Time (encoded as numeric for ranking)
-- study_time values: 'less than 2 hours','2 to 5 hours','5 to 10 hours','greater than 10 hours'
SELECT
    ac.study_time,
    COUNT(DISTINCT ac.student_id)    AS total_students,
    ROUND(AVG(p.avg_grade))      AS avg_score
FROM Academic_Context ac
JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.study_time
ORDER BY 
    CASE ac.study_time
        WHEN 'less than 2 hours'    THEN 1
        WHEN '2 to 5 hours'         THEN 2
        WHEN '5 to 10 hours'        THEN 3
        WHEN 'greater than 10 hours'THEN 4
    END;


-- KPI 3: Attendance Rate
-- (students with 0 absence days / total students * 100)
SELECT
    ROUND(100.0 * SUM(CASE WHEN p.absence_days = 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS attendance_rate,
    ROUND(AVG(p.absence_days), 2) AS avg_absence_days
FROM Performance p;


-- KPI 4: Pass and fail Rate
SELECT
    ROUND(100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END)   / COUNT(*), 2) AS pass_rate,
    ROUND(  100.0 * SUM(CASE WHEN p.status = 'Fail' THEN 1 ELSE 0 END)  / COUNT(*), 2  ) AS fail_rate
FROM Performance p;


-- KPI 5: Performance by Gender
SELECT
    s.gender,
    COUNT(DISTINCT s.student_id)    AS total_students,
    ROUND(AVG(p.final_grade), 2)    AS avg_final_grade,
    SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END) AS pass_count,
    SUM(CASE WHEN p.status = 'Fail' THEN 1 ELSE 0 END) AS fail_count,
    ROUND(100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END)/ COUNT(*), 2) AS pass_rate
FROM Students s
JOIN Performance p ON s.student_id = p.student_id
GROUP BY s.gender;


-- KPI 6: Performance by Parental Education

-- Mother education
SELECT
    'Mother' AS parent_type,
    fb.mother_education AS education_level,
    COUNT(DISTINCT fb.student_id) AS total_students,
    ROUND(AVG(p.avg_grade))    AS avg_score,
    ROUND(100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END)/ COUNT(*), 2) AS pass_rate
FROM Family_Background fb
JOIN Performance p ON fb.student_id = p.student_id
GROUP BY fb.mother_education
 
UNION ALL
-- Father education
SELECT
    'Father' AS parent_type,
    fb.father_education AS education_level,
    COUNT(DISTINCT fb.student_id) AS total_students,
    ROUND(AVG(p.avg_grade))    AS avg_score,
    ROUND(100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pass_rate
FROM Family_Background fb
JOIN Performance p ON fb.student_id = p.student_id
GROUP BY fb.father_education
ORDER BY parent_type, education_level;


-- KPI 7: Internet Access Impact
SELECT
    s.internet,
    COUNT(DISTINCT s.student_id)  AS total_students,
    ROUND(AVG(p.final_grade), 2)  AS avg_final_grade,
    ROUND( 100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pass_rate
FROM Students s
JOIN Performance p ON s.student_id = p.student_id
GROUP BY s.internet;


-- KPI 8: Extracurricular Activities Impact
SELECT
    ac.activities,
    COUNT(DISTINCT ac.student_id) AS total_students,
    ROUND(AVG(p.final_grade), 2)  AS avg_final_grade,
    ROUND(AVG(p.absence_days), 2) AS avg_absence_days,
    ROUND( 100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pass_rate
FROM Academic_Context ac
JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.activities;


-- KPI 9: Failure Rate by School
SELECT
    ac.school,
    COUNT(*)         AS total_records,
    SUM(CASE WHEN p.status = 'Fail' THEN 1 ELSE 0 END) AS total_fails,
    SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END) AS total_pass,
    ROUND(  100.0 * SUM(CASE WHEN p.status = 'Fail' THEN 1 ELSE 0 END) / COUNT(*), 2 ) AS fail_rate_pct,
    ROUND(AVG(p.avg_grade))     AS avg_score
FROM Academic_Context ac
JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.school
ORDER BY fail_rate_pct DESC;


-- KPI 10: Average Absence Days by Study Time
SELECT
    ac.study_time,
    COUNT(DISTINCT ac.student_id)  AS total_students,
    ROUND(AVG(p.absence_days), 2)  AS avg_absence_days
FROM Academic_Context ac
JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.study_time
ORDER BY
    CASE ac.study_time
        WHEN 'less than 2 hours'     THEN 1
        WHEN '2 to 5 hours'          THEN 2
        WHEN '5 to 10 hours'         THEN 3
        WHEN 'greater than 10 hours' THEN 4
    END;


-- KPI 11: Pass Rate by Family Support & School Support
SELECT
    ac.family_support,
    ac.school_support,
    COUNT(*)                       AS total_records,
    ROUND( 100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pass_rate
FROM Academic_Context ac
JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.family_support, ac.school_support
ORDER BY pass_rate DESC;



/* ============================================================
   SECTION 2 — ANALYSIS QUESTIONS
   ============================================================ */



-- Q1: Does studying more hours lead to higher scores?
SELECT
    ac.study_time,
    ROUND(AVG(p.first_grade), 2)   AS avg_first_grade,
    ROUND(AVG(p.second_grade), 2)  AS avg_second_grade,
    ROUND(AVG(p.final_grade), 2)   AS avg_final_grade,
    ROUND(  100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END)  / COUNT(*), 2 ) AS pass_rate
FROM Academic_Context ac
JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.study_time
ORDER BY
    CASE ac.study_time
        WHEN 'less than 2 hours'     THEN 1
        WHEN '2 to 5 hours'          THEN 2
        WHEN '5 to 10 hours'         THEN 3
        WHEN 'greater than 10 hours' THEN 4
    END;



-- Q2: How does attendance affect exam results?
-- Bucketed absence days for cleaner visualization
SELECT
    CASE
        WHEN p.absence_days = 0        THEN '0 days (Perfect)'
        WHEN p.absence_days BETWEEN 1 AND 5   THEN '1-5 days'
        WHEN p.absence_days BETWEEN 6 AND 10  THEN '6-10 days'
        WHEN p.absence_days BETWEEN 11 AND 20 THEN '11-20 days'
        ELSE '20+ days'
    END AS absence_bucket,
    ROUND(AVG(p.final_grade), 2)   AS avg_final_grade,
    ROUND( 100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END) / COUNT(*), 2 ) AS pass_rate_pct
FROM Performance p
GROUP BY absence_bucket
ORDER BY MIN(p.absence_days);


-- Q3: Does participating in extracurricular activities improve grades?
SELECT
    ac.activities,
    COUNT(DISTINCT ac.student_id)  AS total_students,
    ROUND(AVG(p.absence_days), 2)  AS avg_absence_days,
    ROUND( 100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END)/ COUNT(*), 2 ) AS pass_rate
FROM Academic_Context ac
JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.activities 
ORDER BY ac.activities;


-- Q4: Does having internet access affect student performance?
SELECT
    s.internet,
    s.address,
    ROUND(AVG(p.final_grade), 2)   AS avg_final_grade,
    ROUND(AVG(p.absence_days), 2)  AS avg_absence_days,
    ROUND( 100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END)/ COUNT(*), 2) AS pass_rate_pct
FROM Students s
JOIN Performance p ON s.student_id = p.student_id
GROUP BY s.internet, s.address
ORDER BY s.internet, s.address;


-- Q5: Performance difference between male and female students
SELECT
    s.gender,
    ROUND(AVG(p.first_grade), 2)   AS avg_first_grade,
    ROUND(AVG(p.second_grade), 2)  AS avg_second_grade,
    ROUND(AVG(p.final_grade), 2)   AS avg_final_grade,
    ROUND(AVG(p.absence_days), 2)  AS avg_absence_days,
    ROUND(100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END) / COUNT(*), 2 ) AS pass_rate_pct
FROM Students s
JOIN Performance p ON s.student_id = p.student_id
GROUP BY s.gender
ORDER BY s.gender;


-- Q6: How does parental education influence student scores?
SELECT
    fb.mother_education,
    fb.father_education,
    COUNT(DISTINCT fb.student_id)  AS total_students,
    ROUND(AVG(p.final_grade), 2)   AS avg_final_grade,
    ROUND( 100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pass_rate_pct
FROM Family_Background fb
JOIN Performance p ON fb.student_id = p.student_id
GROUP BY fb.mother_education, fb.father_education
ORDER BY avg_final_grade DESC;


-- Q7: Are students who study more also attending more regularly?
-- (correlation between study time & absence days)
SELECT
    ac.study_time,
    COUNT(DISTINCT ac.student_id)  AS total_students,
    ROUND(AVG(p.absence_days), 2)  AS avg_absence_days,
    MIN(p.absence_days)            AS min_absence,
    MAX(p.absence_days)            AS max_absence
FROM Academic_Context ac
JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.study_time
ORDER BY
    CASE ac.study_time
        WHEN 'less than 2 hours'     THEN 1
        WHEN '2 to 5 hours'          THEN 2
        WHEN '5 to 10 hours'         THEN 3
        WHEN 'greater than 10 hours' THEN 4
    END;



-- Q8: Does travel time to school affect performance?
SELECT
    ac.travel_time,
    COUNT(DISTINCT ac.student_id)  AS total_students,
    ROUND(AVG(p.absence_days), 2)  AS avg_absence_days,
    ROUND(100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END)/ COUNT(*), 2 ) AS pass_rate_pct
FROM Academic_Context ac
JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.travel_time
ORDER BY
    CASE ac.travel_time
        WHEN 'less than 15 min'  THEN 1
        WHEN '15 to 30 min'      THEN 2
        WHEN '30 to 60 min'      THEN 3
        WHEN 'greater than 60 min' THEN 4
    END;



-- Q9: Do students with paid tutoring perform better?
SELECT
    ac.paid,
    COUNT(DISTINCT ac.student_id)  AS total_students,
    ROUND(AVG(p.final_grade), 2)   AS avg_final_grade,
    ROUND(100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END)/ COUNT(*), 2) AS pass_rate_pct
FROM Academic_Context ac
JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.paid
ORDER BY ac.paid;




-- Q10: Does romantic relationship status impact grades?
SELECT
    s.romantic,
    s.gender,
    COUNT(DISTINCT s.student_id)   AS total_students,
    ROUND(AVG(p.final_grade), 2)   AS avg_final_grade,
    ROUND(AVG(p.absence_days), 2)  AS avg_absence_days,
    ROUND(100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END)/ COUNT(*), 2) AS pass_rate_pct
FROM Students s
JOIN Performance p ON s.student_id = p.student_id
GROUP BY s.romantic, s.gender
ORDER BY s.romantic, s.gender;



-- Q11: Does guardian type affect outcomes?
SELECT
    fb.guardian,
    COUNT(DISTINCT fb.student_id)  AS total_students,
    ROUND(AVG(p.final_grade), 2)   AS avg_final_grade,
    ROUND(AVG(p.absence_days), 2)  AS avg_absence_days,
    ROUND(100.0 * SUM(CASE WHEN p.status = 'Pass' THEN 1 ELSE 0 END)/ COUNT(*), 2) AS pass_rate_pct
FROM Family_Background fb
JOIN Performance p ON fb.student_id = p.student_id
GROUP BY fb.guardian
ORDER BY avg_final_grade DESC;




-- Q12: Which single factor has the strongest impact on final grade?
-- (Separate breakdowns — compare avg_score variance across each factor)
 
-- Factor: Study Time
SELECT 'study_time' AS factor, ac.study_time AS value,
    ROUND(AVG(p.final_grade),2) AS avg_final_grade
FROM Academic_Context ac JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.study_time
UNION ALL
-- Factor: Internet Access
SELECT 'internet', s.internet,
    ROUND(AVG(p.final_grade),2)
FROM Students s JOIN Performance p ON s.student_id = p.student_id
GROUP BY s.internet
UNION ALL
-- Factor: Activities
SELECT 'activities', ac.activities,
    ROUND(AVG(p.final_grade),2)
FROM Academic_Context ac JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.activities
UNION ALL
-- Factor: Family Support
SELECT 'family_support', ac.family_support,
    ROUND(AVG(p.final_grade),2)
FROM Academic_Context ac JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.family_support
UNION ALL
-- Factor: School Support
SELECT 'school_support', ac.school_support,
    ROUND(AVG(p.final_grade),2)
FROM Academic_Context ac JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.school_support
UNION ALL
-- Factor: Paid Tutoring
SELECT 'paid_tutoring', ac.paid,
    ROUND(AVG(p.final_grade),2)
FROM Academic_Context ac JOIN Performance p ON ac.student_id = p.student_id
GROUP BY ac.paid
UNION ALL
-- Factor: Romantic Relationship
SELECT 'romantic', s.romantic,
    ROUND(AVG(p.final_grade), 2)
FROM Students s JOIN Performance p ON s.student_id = p.student_id
GROUP BY s.romantic
UNION ALL
-- Factor: Address (Urban/Rural)
SELECT 'address', s.address,
    ROUND(AVG(p.final_grade), 2)
FROM Students s JOIN Performance p ON s.student_id = p.student_id
GROUP BY s.address
 
ORDER BY factor,value ;




/* ============================================================
   SECTION 3 : FULL MASTER VIEW FOR POWER BI
   (Join all tables into one flat view — useful for slicers)
   ============================================================ */



CREATE VIEW vw_student_full AS
SELECT
    s.student_id,
    s.gender,
    s.age,
    s.address,
    s.nursery,
    s.internet,
    s.romantic,
 
    fb.family_size,
    fb.parents_status,
    fb.mother_education,
    fb.father_education,
    fb.mother_job,
    fb.father_job,
    fb.guardian,
    fb.family_relationship_quality,
 
    ac.school,
    ac.reason,
    ac.travel_time,
    ac.study_time,
    ac.family_support,
    ac.school_support,
    ac.paid,
    ac.activities,
    ac.wants_higher_education,
 
    lh.freetime,
    lh.go_out,
    lh.health,
    lh.failures,
 
    p.subject,
    p.absence_days,
    p.first_grade,
    p.second_grade,
    p.final_grade,
    p.avg_grade,
    p.status,
    p.level
 
FROM Students s
JOIN Family_Background fb  ON s.student_id = fb.student_id
JOIN Academic_Context  ac  ON s.student_id = ac.student_id
JOIN Lifestyle_Health  lh  ON s.student_id = lh.student_id
JOIN Performance       p   ON s.student_id = p.student_id;


