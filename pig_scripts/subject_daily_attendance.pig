-- Remove old output if exists
rmf /attendance/output/subject_daily_attendance;

-- Load attendance data

data = LOAD '/attendance/attendance.csv'
USING PigStorage(',')
AS (date:chararray, subject:chararray, rollno:int, name:chararray, status:chararray);

-- Filter only present students

present_data = FILTER data BY status == 'Present';

-- Group by date and subject

grp = GROUP present_data BY (date, subject);

-- Count present students

result = FOREACH grp
GENERATE
group.date AS date,
group.subject AS subject,
COUNT(present_data) AS present_students;

-- Store result in HDFS

STORE result INTO '/attendance/output/subject_daily_attendance' USING PigStorage(',');