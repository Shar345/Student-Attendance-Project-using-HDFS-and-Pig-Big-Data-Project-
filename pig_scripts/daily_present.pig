-- Remove old output if it already exists
rmf /attendance/output/daily_attendance;

-- Load attendance data

data = LOAD '/attendance/attendance.csv'
USING PigStorage(',')
AS (date:chararray, subject:chararray, rollno:int, name:chararray, status:chararray);

-- Filter only present students

present_data = FILTER data BY status == 'Present';

-- Group by date

grp_date = GROUP present_data BY date;

-- Count present students per day

daily_attendance = FOREACH grp_date
GENERATE
group AS date,
COUNT(present_data) AS present_students;

-- Store new result

STORE daily_attendance INTO '/attendance/output/daily_attendance' USING PigStorage(',');