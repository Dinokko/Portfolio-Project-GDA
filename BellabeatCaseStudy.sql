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

-- 


