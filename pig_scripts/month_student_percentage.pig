-- Remove old output if exists
rmf /attendance/output/month_student_percentage;

-- Load attendance data

data = LOAD '/attendance/attendance.csv'
USING PigStorage(',')
AS (date:chararray, subject:chararray, rollno:int, name:chararray, status:chararray);

-- Extract month (YYYY-MM)

data_month = FOREACH data GENERATE
SUBSTRING(date,0,7) AS month,
rollno,
name,
status;

-- Group by month and student

grp = GROUP data_month BY (month,rollno,name);

-- Calculate attendance percentage

result = FOREACH grp {

    total_classes = COUNT(data_month);

    present_data = FILTER data_month BY status == 'Present';

    present_classes = COUNT(present_data);

    percentage = (present_classes * 100.0) / total_classes;

    GENERATE
    group.month,
    group.rollno,
    group.name,
    percentage;
};

-- Store result in HDFS

STORE result INTO '/attendance/output/month_student_percentage' USING PigStorage(',');