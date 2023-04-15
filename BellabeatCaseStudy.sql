-- USED 3 TABLES: DailyActivity, WeightLogInfo & SleepLog

-- Checked for distinct values in DailyActivity:

SELECT DISTINCT Id FROM DailyActivity;
# Pulled 33 results

-- Checked for distinct values in WeightLogInfo:

SELECT DISTINCT Id FROM WeightLogInfo;
# Pulled 8 results

-- Checked for distinct values in SleepLog:

SELECT DISTINCT Id FROM SleepLog;
# Pulled 24 results

-- Checked for duplicate values in DailyActivity:

SELECT Id, COUNT(*) AS numRow
FROM DailyActivity
GROUP BY Id, ActivityDate
HAVING COUNT(Id) > 1;
# Returned none

-- Checked for duplicate values in WeightLogInfo:

SELECT Id, COUNT(*) AS numRow
FROM WeightLogInfo
GROUP BY Id, Date, WeightKg, WeightPounds, Fat, BMI, IsManualReport, LogId
HAVING COUNT(*) > 1;
# Returned none

-- Checked for duplicate values in SleepLog:

SELECT Id, COUNT(*) AS numRow
FROM SleepLog
GROUP BY Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
HAVING COUNT(*) > 1;
# Returned 3 values

-- Create new table with distinct values from SleepLog:

SELECT DISTINCT Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
INTO SleepLog2
FROM SleepLog;
# Created SleepLog2 table

-- Rename SleepLog table and then give SleepLog2 table SleepLog name:

EXEC SP_RENAME 'SleepLog', 'DeletedTable';
EXEC SP_RENAME 'SleepLog2', 'SleepLog';
# Renames SleepLog to DeletedTable and SleepLog2 to SleepLog

-- Delete DeletedTable:

DROP TABLE IF EXISTS SleepLog2;
# Deletes table

-- Checking DailyActivity for zero step days:

SELECT SUM(ZeroDays) AS numZeroDays
FROM (
	SELECT COUNT(*) AS ZeroDays
	FROM DailyActivity
	WHERE TotalSteps = 0
) AS t
# Returned 77 entries

-- Checking other categories of days which had zero steps counted:

SELECT *, ROUND((SedentaryMinutes / 60), 2) AS SedentaryHours
FROM DailyActivity
WHERE TotalSteps = 0
# Returned many entries with 24 hours of no activity. Most likely due to the FitBit not being worn.

-- Removing 0 step day rows from the table:

DELETE 
FROM DailyActivity
WHERE TotalSteps = 0
# Removed 77 rows

-- Updating Boolean values in WeightLogInfo to True/False:

ALTER TABLE WeightLogInfo
ALTER COLUMN IsManualReport varchar(255);
# Changed datatype from boolean to string

UPDATE WeightLogInfo
SET IsManualReport = 'True'
WHERE IsManualReport = '1'
# Changes 1 to True

UPDATE WeightLogInfo
SET IsManualReport = 'False'
WHERE IsManualReport = '0'
# Changes 0 to False

-- 


