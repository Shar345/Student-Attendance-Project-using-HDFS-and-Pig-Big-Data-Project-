-- Remove old output if it already exists
rmf /attendance/output/percentage_attendance;

-- Load attendance data

data = LOAD '/attendance/attendance.csv'
USING PigStorage(',')
AS (date:chararray, subject:chararray, rollno:int, name:chararray, status:chararray);

-- Group by student

grp = GROUP data BY (rollno,name);

-- Calculate attendance percentage

result = FOREACH grp {

    total_classes = COUNT(data);

    present_data = FILTER data BY status == 'Present';

    present_classes = COUNT(present_data);

    percentage = (present_classes * 100.0) / total_classes;

    GENERATE
    group.rollno,
    group.name,
    present_classes,
    total_classes,
    percentage;

};

-- Store result in HDFS

STORE result INTO '/attendance/output/percentage_attendance' USING PigStorage(',');